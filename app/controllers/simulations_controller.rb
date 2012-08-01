class SimulationsController < ApplicationController
  require 'lib/openstudio/os_filemanager.rb'
  require 'lib/openstudio/os_geometry.rb'
  require 'lib/openstudio/os_bcl.rb'

  # GET /simulations
  # GET /simulations.xml
  def index
    @simulations = Simulation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @simulations }
    end
  end

  # GET /simulations/1
  # GET /simulations/1.xml
  def show
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @simulation }
    end
  end

  # GET /simulations/new
  # GET /simulations/new.xml
  def new
    @simulation = Simulation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @simulation }
    end
  end

  # GET /simulations/1/edit
  def edit
    @simulation = Simulation.find(params[:id])
  end

  # POST /simulations
  # POST /simulations.xml
  def create
    @simulation = Simulation.new(params[:simulation])

    respond_to do |format|
      if @simulation.save
        format.html { redirect_to(@simulation, :notice => 'Simulation was successfully created.') }
        format.js
        #format.xml  { render :xml => @simulation, :status => :created, :location => @simulation }
      else
        format.html { render :action => "new" }
        format.js
        #xml  { render :xml => @simulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /simulations/1
  # PUT /simulations/1.xml
  def update
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      if @simulation.update_attributes(params[:simulation])
        format.html { redirect_to(@simulation, :notice => 'Simulation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @simulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /simulations/1
  # DELETE /simulations/1.xml
  def destroy
    @simulation = Simulation.find(params[:id])
    @simulation.destroy

    respond_to do |format|
      format.html { redirect_to(simulations_url) }
      format.js  { render :nothing => true }
    end
  end
  
  def create_file_form
    @location = nil
    @states = State.find(:all)
    
    #setup defaults (or use user entered values)
    @defaults = Hash.new
    @defaults[:location] = params.key?(:location) ? params[:location] : 'Denver'
    @defaults[:length] = params.key?(:length) ? params[:length] : 50
    @defaults[:width] = params.key?(:width) ? params[:width] : 50
    @defaults[:height] = params.key?(:height) ? params[:height] : 4.1
    @defaults[:num_floors] = params.key?(:num_floors) ? params[:num_floors] : 1
  
    #check for :location parameter and return to same form with list of fields
    if params.key?(:location)
      @location = params[:location].to_s
    end
    
    #check for :state parameter and return to same form with list of fields
    if params.key?(:state)
      @state = params[:state].to_s
      #check to see if the location is an epw file
      if @state != ""
        #hit the bcl with the string
        if location != ""
          searchforthis = @location + '%20' + @state
        else
          searchforthis = @state
        end
        
        #@bcl_search_string = get_bcl_search_string(searchforthis, "type:nrel_component%20filetype:epw%20tid:169")
        @bcl_locations = get_bcl_search(searchforthis, "sm_component_type:%22Weather%20File")
        
        #check to see if city + state has returned anything.  if not, only search by state
        if @bcl_locations[0].blank?
          @bcl_locations = get_bcl_search(@state, "type:nrel_component%20filetype:epw%20tid:169")
        end
      end     
    end
  end
  
  def create_file
    begin
      @location_id = params[:selected_location]
      
      #download the component
      @epw_filename = ".#{Tempfile.new(['weather', '.zip']).path}"
      get_bcl_component([@location_id], @epw_filename)
      
      #now extract the component (should only be one, and load into the openstudio model)
      comp_dest = File.dirname(@epw_filename) + '/' + File.basename(@epw_filename, File.extname(@epw_filename))
      epw_path_filename = extract_component(@epw_filename, comp_dest)
      
      puts epw_path_filename
      @os_model = get_os_model()
      
      # set weather file
      epw_file = OpenStudio::EpwFile.new(OpenStudio::Path.new(epw_path_filename.to_s))
      weatherFile = OpenStudio::Model::WeatherFile::setWeatherFile(@os_model, epw_file)
      weatherFile.get.setString(9,File.basename(epw_path_filename))
      
      puts "REMOVING COMP DOWNLOAD: #{comp_dest}"
      FileUtils.rm_rf(comp_dest)
      
      @number_of_floors = params[:num_floors].to_i
      
      @fp_array = create_rectangle(params[:length].to_f, params[:width].to_f,
                                   params[:height].to_f, @number_of_floors, true, 3.57)
      
      #create_h_shape(len, width_1, width_2, end_1, end_2, off_1, off_2, off_3, height, number_of_floors, perim_and_core, perim_depth)
      #fp_array = create_h_shape(40, 40, 40, 15, 15, 15, 15, 2, 3.8, number_of_floors, true, 3.57)
      
      fp_cnt = 0
      @fp_array.each do |fp|
        fp_cnt += 1
        (1..@number_of_floors).each do |flr|
          #if suppress multiplers
          create_zoning(@os_model, fp, flr, fp_cnt)
        end
      end
      
      #create the file
      @os_filename = ".#{Tempfile.new(['sim', '.osm']).path}"
      File.open(@os_filename.to_s, 'w') do |f|
        f.puts @os_model.to_s
      end
      
      @idf_filename = ".#{Tempfile.new(['sim', '.idf']).path}"
      translator = OpenStudio::EnergyPlus::ForwardTranslator.new(@os_model)
      @workspace = translator.convert
      if not @workspace.empty?
        begin
          File.open(@idf_filename, 'w') do |file|
            file.puts @workspace.get.toIdfFile.to_s
          end
          result = true
        end
      end
            
      #respond_to do |format|
      #  format.html { redirect_to(@details, :notice => 'File Created.')}
      #  #format.xml  { head :ok }
      #end
	
    end
    GC.start
  end
  
  
  def download_sim
    if params[:download_file] == 'idf'
      send_file params[:idf_filename]
    elsif params[:download_file] == 'epw'
      send_file params[:epw_filename]
    else
      send_file params[:os_filename]
    end
  end
end
