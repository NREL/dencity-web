class ApisController < ApplicationController

  require 'crack' # for xml and json
  #devise
  before_filter :authenticate_user!
  #cancan
  before_filter { unauthorized! if cannot? :read, :api }
  
  #####***********API Version 1*************#####
  
  #POST /api/v1/submit_building
  #POST /api/v1/submit_building.xml
  def submit_building_v1
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
    bld = Edifice.find_or_create_by(:unique_name => thename)
    bld.user_id = current_user.id
  
    #create descriptors and values
    bld.process_descriptor_data_v1(data)
 
    respond_to do |format|
      if bld.save
        format.html { redirect_to(@edifice, :notice => 'Building was successfully created.') }
        format.xml  { render :xml => 'The building was successfully uploaded.', :status => :created}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edifice.errors, :status => :unprocessable_entity }
      end
    end
  end

  #GET /api/v1/retrieve
  #GET /api/v1/retrieve.xml
  #def retrieve_v1
    
  #end
  

end
