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
    logger.info("the name is: #{thename}")
    bld = Edifice.find_or_create_by(:name => thename)
    logger.info("#{bld}")
  
    keys1 = data.keys
    logger.info("the keys are: #{keys1.inspect}, size: #{keys1.size}")
    #keys1.each do |key1|
    key1 = keys1[0]
      #only do "attribute" keys (top-level will be an attribute tag)
      if key1 == "Attribute"     
        innerhash = data[key1]
        logger.info("class:#{innerhash.class}")
        if innerhash.class.to_s.casecmp("Hash")
          #2nd level
          keys2 = innerhash.keys
          logger.info("2nd-level keys are: #{keys2.inspect}, size: #{keys2.size}")
          #at this point there could be some keys and another nested attribute key
          keys2.each do |key2|
            if key2 == 'Name'
              name2 = data[key1][key2]
              logger.info("name2: #{name2}")
            elsif key2 == 'ValueType'
              valuetype2 = data[key1][key2]
              logger.info("valuetype2: #{valuetype2}")
            elsif key2 == "Units"
              units2 = data[key1][key2]
              logger.info("units2: #{units2}")
            elsif key2 == "Value"
              #check what valuetype was, if attributevector, we have another nesting, send to separate function?
              #need to pass in: <value> vector, current name(in case we need it)
              if valuetype2 == 'AttributeVector'
                logger.info("sending data to process_data function:  #{data[key1][key2]}")
                #process_data(data[key1][key2], name2)
              else
                logger.info("simple value, no need to send")
                value2 = data[key1][key2]
                logger.info("value2 : #{value2}")
              end
            end            
          end
          
          if valuetype2 != 'AttributeVector'
            #save simple value function
            logger.info("save it!")
          #  #create/update descriptor
            descriptor = Descriptor.find_or_create_by(:name => name2)
            logger.info("created descriptor #{descriptor._id}")
           
            if !descriptor.units.nil?
          #    #TODO compare units and convert if necessary
            else
              descriptor.units = units2
            end
            if descriptor.value_type.nil?
              descriptor.value_type = valuetype2
            end
            descriptor.save!
            logger.info("descriptor saved, id is #{descriptor._id}")

            #save value in building            
            logger.info("the building is #{bld.inspect}")                 
                        
            bld.descriptor_values.find_or_create_by(:descriptor_id => descriptor._id)
            
            logger.info("the building has descriptors #{bld.descriptor_values.inspect}")  
    
=begin 
            building.save!
          #  building.set_value_from_descriptor_id(descriptor._id, value2)
=end 
          end
         
        else
          #no more levels?
          logger.info("no level2 info")
        end

      end
    #end

    #parsedfile.each_pair do |key, value|
    #  #looking for "Attribute" keys
    #  logger.info("key: #{key}, value: #{value}, class: #{value.class}")
    #  
    #  #parsedfile[key]
    #  
    #  #if key == 'Attribute'
    #  #  #check out the "value", could be a hash
    #  #  if value.is_a?(Hash)
    #  #    #need another loop
    #  #    value.each_pair do |key2, value2|
    #  #      logger.info("key: #{key}, value: #{value}")
    #  #    end
    #  #  end
    #  #end
    #  
    #end

    respond_to do |format|
      if @edifice == 1 #@edifice.save
        format.html { redirect_to(@edifice, :notice => 'Building was successfully created.') }
        #format.xml  { render :xml => @edifice, :status => :created, :location => @building }
        format.xml  { render :xml => 'hi', :status => :created}
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
