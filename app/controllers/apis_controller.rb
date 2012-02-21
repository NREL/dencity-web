class ApisController < ApplicationController

  require 'crack' # for xml and json
  #devise
  before_filter :authenticate_user!
  #cancan
  before_filter { unauthorized! if cannot? :read, :api }
  
  #####***********API Version 1*************#####
  
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
        #assume it is straight xml
        xml_contents = params[:xmlfile]
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
    thetime = Time.now
    thename = "Building" + thetime.strftime("%Y%m%d-%H%M%S")
    #logger.info("the name is: #{thename}")
    bld = Edifice.find_or_create_by(:unique_name => thename)
    bld.user_id = current_user.id
    bld.created_at = thetime
  
    #create descriptors and values
    bld.process_descriptor_data_v1(data)
    
    #extract lat/lng and store as coordinates
    bld.get_coordinates_v1()
    
    #TODO: put in a check here in case the bld gets saved without any attributes (in case the xml is badly formulated or something)
 
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
  
  def submit_preprocessor_v1
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
        #assume it is straight xml
        xml_contents = params[:xmlfile]
      end
    end
    
    logger.info("the file is: #{thefile}")    
    logger.info("xml contents are: #{xml_contents}")
    
    # persist off and preprocess
    
    # return the generated IDF
    
    
    
  end


  #POST /api/v1/retrieve_building.xml
  def retrieve_building_v1
    
    #look at params hash for a descriptor and a value
    #retrieve 1 building matching the value
    #if none match, retrieve closest building (up or down)
    descriptor = params[:descriptor] ? params[:descriptor] : nil
    value = params[:value] ? params[:value] : nil
     
    if !descriptor.nil? and !value.nil? 
      #see what the descriptor's valuetype is (string vs float)
      d = Descriptor.where('name' => descriptor).first
      if d.value_type == "String"
        #find exact match
        res = Edifice.where(descriptor => value).limit(1).first
        retval = !res.nil? ? res : 'No results match your search'      
      else
        #find closest match (in either direction)
        #query with this info (upper and lower bounds, pick closest)
        res1 = Edifice.where(descriptor => {"$gte" => value}).limit(1).first
        res2 = Edifice.where(descriptor => {"$lte" => value}).limit(1).first
   
        diff1 = !res1.nil? ? (res1[descriptor].to_f - value.to_f) : nil
        diff2 = !res2.nil? ? (value.to_f - res2[:descriptor].to_f) : nil
        
        #which one to pick?
        if !diff1.nil? and !diff2.nil?
          if diff1 < diff2
            #return diff1
            retval = res1
          else
            #return diff2
            retval = res2
          end
        elsif !diff1.nil?
          #return res1
          retval = res1
        elsif !diff2.nil?
          #return res2
          retval = res2
        else
          #no results
          retval = 'No results match your search'
        end  
      end
    else
      #return NO results
      retval = 'No results match your search'
    end
  
    respond_to do |format|
      format.xml  { render :xml => retval.to_xml}
    end
  end
  
  #POST /api/v1/get_descriptors.xml
  
  def list_descriptors_v1
    
    descriptors = Descriptor.find(:all)
    
    respond_to do |format|
      format.xml  { render :xml => descriptors.to_xml}
    end
    
  end

end
