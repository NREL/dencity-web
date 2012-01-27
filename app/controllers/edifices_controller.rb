class EdificesController < ApplicationController
  
  require 'crack' # for xml and json
  
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
    #@edifice = Edifice.new(params[:edifice])
    @edifice = 1
    thefile = nil
    xml_contents = nil

    #get file and read it in (expecting file parameter named :xmlfile)
    if params[:xmlfile]
      thefile = params[:xmlfile]
      if thefile.respond_to?(:read)
        xml_contents = thefile.read
      elsif thefile.respond_to?(:path)
        xml_contents = File.read(thefile.path)
      else
        xml_contents = 'bad'
      end
    end
    
    logger.info("the file is: #{thefile}")    
    logger.info("xml contents are: #{xml_contents}")
    
    #now parse the file
    #KAF: check on this, but is max 4-levels of nesting?
    data = Crack::XML.parse(xml_contents)
    logger.info("the parsed contents are: #{data.inspect}")

    #initialize some variables to do the parsing
    valuetype2 = nil
    units2 = nil
    value2 = nil
    name2 = nil

    #for now create a random building name
    thename = "Building" + Time.now.strftime("%Y%m%d-%H%M%S")
    #logger.info("the name is: #{thename}")
    bld = Edifice.find_or_create_by(:name => thename)
    bld.user_id = @apiuser._id
  
    #create descriptors and values
    bld.process_descriptor_data(data)
 
    respond_to do |format|
      if !bld.nil?
        format.html { redirect_to(@edifice, :notice => 'Building was successfully created.') }
        format.xml  { render :xml => bld, :status => :created}
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
end
