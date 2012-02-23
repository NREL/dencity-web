class InputsController < ApplicationController
  require 'rserve/simpler'
  require 'orderedhash'
  require 'RMagick'

  # GET /inputs/inputs
  # GET /inputs/inputs.xml
  def inputs
    @input = Input.new
    
    @building_types = get_building_types()
    @climate_zones = get_climate_zones()

  end
  
  # POST /inputs/process_inputs
  # POST /inputs/process_inputs.xml
  def process_inputs
    @input = Input.new(params[:input])
    @input.created_at = Time.now
    
    #get lat/lng from address
    loc = @input.address
    @coords = Geocoder.coordinates(loc)
   
    @debug = "Parameters: #{loc}\n\n"
    @debug += "Coordinates: #{Geocoder.coordinates(loc).to_s}"
     
    @edis = Edifice.near(loc, 50)
        
    if @edis.size == 0
      @debug = Geocoder.search(loc).inspect
    end
    
    #convert units
    if !@input.wall_u_factor.nil?
      @input.convert('wall_u_factor', 'u-IP', 'u-SI')
    end
    if !@input.attic_u_factor.nil?
      @input.convert('attic_u_factor', 'u-IP', 'u-SI')
    end   
    if !@input.lighting_power_density.nil?
      @input.convert('lighting_power_density', 'W/ft2', 'W/m2')
    end
    if !@input.height_north.nil?
      @input.convert('height_north', 'ft', 'm')
    end
    if !@input.height_south.nil?
      @input.convert('height_south', 'ft', 'm')
    end
    if !@input.height_east.nil?
      @input.convert('height_east', 'ft', 'm')
    end
    if !@input.height_west.nil?
      @input.convert('height_west', 'ft', 'm')
    end
    
    @input.save
    
    #use R to do statistics
    @r = Rserve::Simpler.new

    var_array = [
                  {:short_name => "tdv", :output => true, :var_name => "time_dependent_valuation", :dataarr => []},
                  {:short_name => "heating", :var_name => "site_energy_use_heating", :dataarr => []},
                  {:short_name => "cooling", :var_name => "site_energy_use_cooling", :dataarr => []},
                  {:short_name => "lpd", :var_name => "lighting_power_density", :dataarr => []},
                  {:short_name => "building_ufactor", :var_name => "building_u_factor", :dataarr => []},
                  {:short_name => "wall_u_factor", :var_name => "wall_u_factor", :dataarr => []},
                  {:short_name => "attic_u_factor", :var_name => "attic_u_factor", :dataarr => []},
                  {:short_name => "wwr_west", :var_name => "west_facade_window_to_wall_ratio", :dataarr => []},
                  {:short_name => "wwr_south", :var_name => "south_facade_window_to_wall_ratio", :dataarr => []},
                  {:short_name => "sill_height_south", :var_name => "south_facade_sill_height", :dataarr => []}                  
                ]
    
    
    @edis.each do |edi|
      var_array.each do |var|
        var[:dataarr] << edi["#{var[:var_name]}"].to_f
      end
    end
    
    hash = OrderedHash.new
    var_array.each do |var|
      hash[var[:short_name]] = var[:dataarr]
    end
    
    datafr = Rserve::DataFrame.new(hash)
    datafr_summary = @r.converse("summary(df)", :df => datafr).in_groups(var_array.size)
    @reply = []
    datafr.colnames.zip(datafr_summary) do |name, data|
      #deconstruct the data result
      store_data = {}
      data.each do |datum|
        store_data[datum[0..6].rstrip.downcase.gsub(".","").gsub(" ","")] =
          datum[8..datum.size].rstrip
      end
      @reply << {:name => "#{name}", :data => store_data }
    end

    # array of images for analysis
    @images = []
    
    #correlations
    @corr_summary = @r.converse("cor(df)", :df => datafr).to_a

    #regressions
    lm_string = "lm(tdv ~ #{var_array.map{ |val| val[:short_name] if val[:output] != true }.join(" + ")}, data=df)"
    @lm = @r.converse(lm_string, :df => datafr)
    @lm_summary = @r.converse("summary(fit)", :fit => @lm)
    @lm = var_array.map{ |val| val[:short_name]}.zip(@lm[0])
    @lm[0][0] = "intercept"
    
    puts @lm_summary.inspect
    
    image = {:group => "general", :name => "fit_diagnostics"}.merge(get_image_tempfiles)
    @images << image
    @r.command( :df => datafr ) do 
      %Q{
        png("#{image[:fullpath]}", width = 1024, height = 1024)
        fit <- lm(tdv ~ lpd + building_ufactor + wall_u_factor, data=df)
        layout(matrix(c(1,2,3,4),2,2)) 
        plot(fit, lwd=2, density=4)
        dev.off()
      }
    end
    img_orig = Magick::Image.read(image[:fullpath]).first
    img = img_orig.resize_to_fill(200,200)
    img.write(image[:fullpath_tn])
    
    
    #standard plots for all data sets
    image = {:group => "general", :name => "all_dim"}.merge(get_image_tempfiles)
    @images << image
    @r.command( :df => datafr ) do 
      %Q{
        png("#{image[:fullpath]}", width = 1024, height = 1024)
        plot(df, lwd=2, density=4)
        dev.off()
      }
    end
    img_orig = Magick::Image.read(image[:fullpath]).first
    img = img_orig.resize_to_fill(200,200)
    img.write(image[:fullpath_tn])
  
    var_array.each do |var|
      (1..2).each do |plot|
        #create generic plots
        image = {:group => "variable", :name => var[:short_name]}.merge(get_image_tempfiles)
        @images << image
      
        if plot == 1      
          @r.command( :df => datafr ) do 
            %Q{
              png("#{image[:fullpath]}", width = 800, height = 800)
              hist(df$"#{var[:short_name]}", lwd=4, density=10)
              dev.off()
            }
          end
        elsif plot == 2
          @r.command(:group => "variable", :df => datafr ) do 
            %Q{
              png("#{image[:fullpath]}", width = 800, height = 800)
              boxplot(df$"#{var[:short_name]}", lwd=4, density=10)
              dev.off()
            }
          end
        end
        
        img_orig = Magick::Image.read(image[:fullpath]).first
        img = img_orig.resize_to_fill(200,200)
        img.write(image[:fullpath_tn])
      end
    end
  end

=begin
  # GET /inputs
  # GET /inputs.xml
  def index
    @inputs = Input.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inputs }
    end
  end

  # GET /inputs/1
  # GET /inputs/1.xml
  def show
    @input = Input.find(params[:id])
    attrs = @input.attributes
    @keys = attrs.keys

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @input }
    end
  end

  # GET /inputs/1/edit
  def edit
    @input = Input.find(params[:id])
  end

  # GET /inputs/new
  # GET /inputs/new.xml
  def new
    @input = Input.new
    @building_types = get_building_types()
    @climate_zones = get_climate_zones()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @input }
    end
  end


  # POST /inputs
  # POST /inputs.xml
  def create
    @input = Input.new(params[:input])
    @input.created_at = Time.now

    respond_to do |format|
      if @input.save
        format.html { redirect_to(@input, :notice => 'Input was successfully created.') }
        format.xml  { render :xml => @input, :status => :created, :location => @input }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @input.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inputs/1
  # PUT /inputs/1.xml
  def update
    @input = Input.find(params[:id])

    respond_to do |format|
      if @input.update_attributes(params[:input])
        format.html { redirect_to(@input, :notice => 'Input was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @input.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inputs/1
  # DELETE /inputs/1.xml
  def destroy
    @input = Input.find(params[:id])
    @input.destroy

    respond_to do |format|
      format.html { redirect_to(inputs_url) }
      format.xml  { head :ok }
    end
  end
=end 
  
  private
  def get_climate_zones
    #get climate zones by group
    @climate_zones =
    {
      'ASHRAE 90.1 2004' => [['1A', 'ASHRAE 90.1 2004 Zone 1A'],
                             ['1B', 'ASHRAE 90.1 2004 Zone 1B'],
                             ['2A', 'ASHRAE 90.1 2004 Zone 2A'],
                             ['2B', 'ASHRAE 90.1 2004 Zone 2B'],
                             ['3A', 'ASHRAE 90.1 2004 Zone 3A'],
                             ['3B', 'ASHRAE 90.1 2004 Zone 3B'],
                             ['3C', 'ASHRAE 90.1 2004 Zone 3C'],
                             ['4A', 'ASHRAE 90.1 2004 Zone 4A'],
                             ['4B', 'ASHRAE 90.1 2004 Zone 4B'],
                             ['4C', 'ASHRAE 90.1 2004 Zone 4C'],
                             ['5A', 'ASHRAE 90.1 2004 Zone 5A'],
                             ['5B', 'ASHRAE 90.1 2004 Zone 5B'],
                             ['5C', 'ASHRAE 90.1 2004 Zone 5C'],
                             ['6A', 'ASHRAE 90.1 2004 Zone 6A'],
                             ['6B', 'ASHRAE 90.1 2004 Zone 6B'],
                             ['7', 'ASHRAE 90.1 2004 Zone 7'],
                             ['8', 'ASHRAE 90.1 2004 Zone 8']],
      
      'CEC Title 24 2008' => [['1', 'CEC Title 24 2008 Zone 1'],
                              ['2', 'CEC Title 24 2008 Zone 2'],
                              ['3', 'CEC Title 24 2008 Zone 3'],
                              ['4', 'CEC Title 24 2008 Zone 4'],
                              ['5', 'CEC Title 24 2008 Zone 5'],
                              ['6', 'CEC Title 24 2008 Zone 6'],
                              ['7', 'CEC Title 24 2008 Zone 7'],
                              ['8', 'CEC Title 24 2008 Zone 8'],
                              ['9', 'CEC Title 24 2008 Zone 9'],
                              ['10', 'CEC Title 24 2008 Zone 10'],
                              ['11', 'CEC Title 24 2008 Zone 11'],
                              ['12', 'CEC Title 24 2008 Zone 12'],
                              ['13', 'CEC Title 24 2008 Zone 13'],
                              ['14', 'CEC Title 24 2008 Zone 14'],
                              ['15', 'CEC Title 24 2008 Zone 15'],
                              ['16', 'CEC Title 24 2008 Zone 16']],
    }
    
  end
  
  def get_building_types
    #reference building types
    @building_types = 
      ['Large Office',
       'Medium Office',
       'Small Office',
       'Warehouse',
      'Stand-Alone Retail',
      'Strip Mall',
      'Primary School',
      'Secondary School',
      'Supermarket',
      'Quick Service Restaurant',
      'Full Service Restaurant',
      'Hospital',
      'Outpatient Health Care',
      'Small Hotel',
      'Large Hotel',
      'Midrise Apartment']
    
  end
  
  def get_image_tempfiles
    image = {}
    Dir.mkdir("#{Rails.root}/public/images/R") if not File.exists?("#{Rails.root}/public/images/R")
    image[:fullpath] = Tempfile.new("images/R/", Rails.root.join('public')).path + '.png'
    image[:fullpath_tn] = Tempfile.new("images/R/", Rails.root.join('public')).path + '.png'
    image[:relpath] = image[:fullpath].gsub("#{Rails.root}/public", "")
    image[:relpath_tn] = image[:fullpath_tn].gsub("#{Rails.root}/public", "")
    
    image
  end
end
