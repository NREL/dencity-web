class EdificesController < ApplicationController
  
  require 'crack' # for xml and json
  
  #devise
  before_filter :authenticate_user!, :except => [:show, :index, :home]
  #cancan
  load_and_authorize_resource
  skip_before_filter :authorize, :only => [:home]
  
  def home
    
  end
  
  # GET /edifices
  # GET /edifices.xml 
  def index
       
    if params[:page].nil?
      @page = 1
    else
      @page = params[:page] 
    end
    @per = 50
    @uuid = ''
    
    if params[:uuid] and !params[:uuid].blank?
      @uuid = params[:uuid]  
      #only retrieve matching building
      @edifices = Edifice.where("uuid" => @uuid).page(1)
    else
      @edifices = Edifice.order_by("updated_at", :desc).page(@page).per(@per)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @edifices }
    end
  end

  # GET /edifices/1
  # GET /edifices/1.xml
  def show
    @edifice = Edifice.find(params[:id])
    @descriptors = Descriptor.find(:all, :sort => [[:name, :asc]])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edifice }
    end
  end

  # GET /edifices/new
  # GET /edifices/new.xml
  def new
    @edifice = Edifice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edifice }
    end
  end

  # GET /edifices/1/edit
  def edit
    @edifice = Edifice.find(params[:id])
  end

  # POST /edifices
  # POST /edifices.xml
  def create
   @edifice = Edifice.new(params[:edifice])
   @edifice.created_at = Time.now
   
   respond_to do |format|
      if @edifice.save
        format.html { redirect_to(@edifice, :notice => 'Edifice was successfully created.') }
        format.xml  { render :xml => @edifice, :status => :created, :location => @edifice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edifice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /edifices/1
  # PUT /edifices/1.xml
  def update
    @edifice = Edifice.find(params[:id])

    respond_to do |format|
      if @edifice.update_attributes(params[:edifice])
        format.html { redirect_to(@edifice, :notice => 'Edifice was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edifice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /edifices/1
  # DELETE /edifices/1.xml
  def destroy
    @edifice = Edifice.find(params[:id])
    @edifice.destroy

    respond_to do |format|
      format.html { redirect_to(edifices_url) }
      format.xml  { head :ok }
    end
  end
  
  def location
    loc = params[:location]
    @debug = "Parameters: #{loc}\n\n"
    if loc.nil?
      @search_string = "enter location"
    else
      @search_string = loc
    end

    @debug += "Coordinates: "+ Geocoder.coordinates(loc).to_s + "\n\n\n\n"
    
    @submitted = params[:submitted]
    if @submitted
      edis = Edifice.near(loc, 50)
      
      edis.each do |edi|
        #puts "*************************** #{edi}"
        @debug += edi.inspect + "\n\n\n\n"
      end
      
      if edis.size == 0
        @debug = Geocoder.search(loc).inspect
      end
    end
  end
  
  #get all data and return a csv file
  def get_data
    
    @startdate = params[:startdate]
    
    if @startdate.nil?
      #find all buildings
      @edifices = Edifice.find(:all)
    
    else    
      #only get new buildings (temp)
      time = Time.parse(@startdate)
      @edifices = Edifice.where("created_at" => {"$gt" => time})
    
    end
    
    if @edifices.size != 0    
      thedate = Time.now
      thedate = thedate.strftime("%Y%m%d_%H%M%S")
      @filename = "datafile_#{thedate}.csv"
      
      attributes = @edifices[0].attributes
      keys = attributes.keys
      #remove "descriptor_values"
      keys.delete_if {|x| x == "descriptor_values"}
      
      row = []
      
      FasterCSV.open("#{RAILS_ROOT}/public/tmpdata/#{@filename}", "w") do |csv|
        #first get header row
        cnt = 0
        keys.each do |key|
          row[cnt] = key
          cnt += 1
        end
        csv << row
        
        #now get data
        @edifices.each do |bld|
          cnt = 0
          keys.each do |key|
            row[cnt] =  bld[key]
            cnt += 1
          end
          csv << row
        end           
      end
    else
      #no data
      @filename = 'No Data'
    end
  end
  
  def download
    ed = Edifice.find(:first)
    @file ="#{RAILS_ROOT}/public/tmpdata/#{params[:file]}"
    #logger.info(@file)
    #try send_data here
    #send_file(@file, :disposition => 'attachment', :type => 'text/csv')
    send_data(@file, :disposition => 'attachment', :type => 'text/csv', :filename => 'bemscape_data.csv')
  end

  
  
end
