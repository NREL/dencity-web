class ApisController < ApplicationController

  require 'crack' # for xml and json
  #devise
  before_filter :authenticate_user!
  #cancan
  before_filter { unauthorized! if cannot? :read, :api }
  
  #####***********API Version 1*************#####
  
  #PUT /api/v1/update_building.xml
  def update_building_v1
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
    else
      xml_contents = request.raw_post
    end
    
    if !xml_contents.blank?
          
      #set error code to 411
      error_code = :length_required

      #now parse the file
      data = Crack::XML.parse(xml_contents)   
      
      #see if building already exists (by UUID), return 406 if can't find UUID in xml
      the_uuid = get_uuid_from_xml_v1(data)
      if the_uuid == -1
        error_code = :not_acceptable
      else

        if !Edifice.where(:uuid => the_uuid).exists?
          #building doesn't exists, return 409
          error_code = :conflict          
        else
          #for now create a random building name (added random number at the end to make sure it's unique)
          bld = Edifice.where(:uuid => the_uuid).first
          thetime = Time.now
          #KAF:not checking that this is the same userID that submitted the building
          #bld.user_id = current_user.id
          bld.updated_at = thetime
        
          #create descriptors and values
          bld.process_descriptor_data_v1(data)
          
          #extract lat/lng and store as coordinates
          bld.get_coordinates_v1()
          
          if bld.save
            error_code = :created
          else
            error_code = :not_acceptable
          end
   
        end 
      end
    else
      #blank parameters, set to error code 411
      error_code = :length_required
    end   

    respond_to do |format|
      #display differently based on error_code
      if error_code == :created  #201
        format.xml { render :xml => 'SUCCESS: The building was updated.', :status => error_code}
      elsif error_code == :length_required   #411
        format.xml { render :xml => 'ERROR: The request is missing parameters or parameters are blank.', :status => error_code}
      elsif error_code == :not_acceptable  #406
        format.xml { render :xml => 'ERROR: Cannot find unique identifier (UUID) in xml file.', :status => error_code}
      elsif error_code == :conflict #409
        format.xml {render :xml => 'ERROR:  A building with this UUID does not exist in the database.  To create a new building, use the submit_building POST action.', :status => error_code}
      elsif error_code == :bad_request #400
        format.xml {render :xml => 'ERROR:  Unknown Error.', :status => error_code}
      end  
    end        
    
  end
  
  
  
  #POST /api/v1/submit_building.xml
  def submit_building_v1

    thefile = nil
    xml_contents = nil
    inputfile = nil
    inputfile_contents = nil
    #default error_code is 400 : bad_request
    error_code = :bad_request

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
    else
      xml_contents = request.raw_post
    end
    
    if !xml_contents.blank?
      
      #if params[:inputfile]
      #  inputfile = params[:inputfile]
      #  if inputfile.respond_to?(:read)
      #    inputfile_contents = inputfile.read
      #  elsif inputfile.respond_to?(:path)
      #    inputfile_contents = File.read(inputfile.path)
      #  else
      #    #assume that is is IDF?????
      #    inputfile_contents = params[inputfile]
      #  end
      #end      
      
      #set error code to 411
      error_code = :length_required
      
      #logger.error("the file is: #{thefile}")    
      #logger.error("xml contents are: #{xml_contents}")
      
      #logger.error("the input file is: #{inputfile}")    
      #logger.error("input file contents are: #{inputfile_contents}")
      
      #now parse the file
      data = Crack::XML.parse(xml_contents)   
      #logger.error("the parsed contents are: #{data.inspect}")
      
      #see if building already exists (by UUID), return 406 if can't find UUID in xml
      the_uuid = get_uuid_from_xml_v1(data)
      if the_uuid == -1
        error_code = :not_acceptable
      else

        if Edifice.where(:uuid => the_uuid).exists?
          #building already exists, return 409
          error_code = :conflict          
        else
          #for now create a random building name (added random number at the end to make sure it's unique)
          thetime = Time.now
          thename = "Building" + thetime.strftime("%Y%m%d-%H%M%S") + "-#{rand(1000)}"
          bld = Edifice.find_or_create_by(:uuid => the_uuid)
          bld.unique_name = thename
          bld.user_id = current_user.id
          bld.created_at = thetime
        
          #create descriptors and values
          bld.process_descriptor_data_v1(data)
          
          #extract lat/lng and store as coordinates
          bld.get_coordinates_v1()
          
          if bld.save
            error_code = :created
          else
            error_code = :not_acceptable
          end
          
          # Strip off the input payload and save into the database (as a zip????)
          #bld.file_osm = inputfile_contents      
        end 
      end
    else
      #blank parameters, set to error code 411
      error_code = :length_required
    end   

    respond_to do |format|
      #display differently based on error_code
      if error_code == :created  #201
        format.xml { render :xml => 'SUCCESS: The building was uploaded.', :status => error_code}
      elsif error_code == :length_required   #411
        format.xml { render :xml => 'ERROR: The request is missing parameters or parameters are blank.', :status => error_code}
      elsif error_code == :not_acceptable  #406
        format.xml { render :xml => 'ERROR: Cannot find unique identifier (UUID) in xml file.', :status => error_code}
      elsif error_code == :conflict #409
        format.xml {render :xml => 'ERROR:  A building with this UUID already exists in the database.  To update, use the PUT action.', :status => error_code}
      elsif error_code == :bad_request #400
        format.xml {render :xml => 'ERROR:  Unknown Error.', :status => error_code}
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
    
    #logger.info("the file is: #{thefile}")    
    #logger.info("xml contents are: #{xml_contents}")
    
    # persist off and preprocess
    
    # return the generated IDF
    
    
    
  end


  #GET /api/v1/retrieve_building.xml
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
  
  #GET /api/v1/get_descriptors.xml  
  def list_descriptors_v1
    
    descriptors = Descriptor.find(:all)
    
    respond_to do |format|
      format.xml  { render :xml => descriptors.to_xml}
    end
    
  end
  
  private
  
  def get_uuid_from_xml_v1(data)
  
    retval = -1
    thekeys = data.keys
    
    thekeys.each do |key1|
      if key1 == "Attribute"
        #get inner data and process
        innerdata = data[key1]      
        keys2 = innerdata.keys
        #if 1st pass, store UUID
        name2 = keys2.include?("Name") ? data[key1]['Name'] : nil
        if name2 == 'Report'
          if keys2.include?("UUID")
            retval =  data[key1]['UUID']
          end
        end
      end
    end
    return retval
    
  end
end

