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
    @edifices = Edifice.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @edifices }
    end
  end

  # GET /edifices/1
  # GET /edifices/1.xml
  def show
    @edifice = Edifice.find(params[:id])
    @descriptors = Descriptor.find(:all)

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

    @debug += Geocoder.coordinates(loc).to_s + "\n\n\n\n"
    
    @submitted = params[:submitted]
    if @submitted
      edis = Edifice.near(loc, 50)
      
      edis.each do |edi|
        puts "*************************** #{edi}"
        @debug += edi.inspect + "\n\n\n\n"
      end
      
      if edis.size == 0
        @debug = Geocoder.search(loc).inspect
      end
    end
    
  end
end
