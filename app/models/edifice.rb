class Edifice
  include Mongoid::Document
  
  field :unique_name,    :type => String
  
  # Indexes
  index :unique_name,    :unique => true
  
  # Relationships
  referenced_in :descriptor
  referenced_in :user
  embeds_many :descriptor_values
  accepts_nested_attributes_for :descriptor_values
  
  #Class Methods
  def cleanup_name(name)
    
    #look for camel case: downcase and replace spaces by underscores
    newname = name.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    tr(" ", "_").
    tr(".", "_").
    downcase

    return newname
  end
  
  def get_value_from_descriptor(descriptor)
    ret = nil
    self.descriptor_values.each do |dv|
      if dv.descriptor_id == descriptor._id
        ret = dv[:value]
        return ret
      end
    end
    
  end
  
  def set_value_from_descriptor(descriptor, value)
    self.descriptor_values.each do |dv|
      if dv.descriptor_id == descriptor._id
        #old way
        dv[:value] = value
        dv.save!
        #new way
        dv[descriptor.name] = value        
      end
    end
    self.save!
  end
  
  #API METHODS-- VERSION 1!  
  
  #save parsed out descriptor and value from xml file
  def save_descriptor_and_value_v1(name, valuetype, value, units)
    
    #clean-up descriptor name
    newname = self.cleanup_name(name)
    
    #create/update descriptor 
    descriptor = Descriptor.find_or_create_by(:name => newname)
    logger.info("created descriptor #{descriptor._id}")
   
    if !descriptor.units.nil?
      #TODO compare units and convert if necessary
    else
      descriptor.units = units
    end
    if descriptor.value_type.nil?
      descriptor.value_type = valuetype
    end
 
    descriptor.save

    #save value           
    self.descriptor_values.find_or_create_by(:descriptor_id => descriptor._id)
    self.set_value_from_descriptor(descriptor, value)
    
    #also save it straight to the building just to see which way is best
    self[newname]= value
    
              
  end
  
  def process_descriptor_data_v1(data, nested_name=nil)
    #takes a snippet of xml-parsed data, in hash / array format
    
    #parse variables
    valuetype2 = nil
    units2 = nil
    value2 = nil
    name2 = nil
    
    thekeys = data.keys
    
    logger.info("keys are: #{thekeys.inspect}, size: #{thekeys.size}, class: #{data.class}")

    #should have Attribute keys only here?
    thekeys.each do |key1|
      if key1 == "Attribute"
        #get inner data and process
        innerdata = data[key1]
        
        #sometimes this is a hash (only 1 descriptor)
        if innerdata.class.to_s === "Hash"
          #2nd level
          keys2 = innerdata.keys
          logger.info("2nd-level keys are: #{keys2.inspect}, size: #{keys2.size}")
          
          #get attributes
          value2 = keys2.include?("Value") ? data[key1]['Value'] : nil
          name2 = keys2.include?("Name") ? data[key1]['Name'] : nil
          name2 = keys2.include?("DisplayName") ? data[key1]['DisplayName'] : name2
          #append name to nested_name to keep path (underscore separated)
          if !nested_name.nil? and nested_name != 'Report'
            name2 = nested_name + '_' + name2
          end
         
          if keys2.include?("ValueType") and data[key1]['ValueType'] == 'AttributeVector'
            #send to processing
            logger.info("sending data to process_data function:  #{value2}")
            self.process_descriptor_data_v1(value2, name2)            
          else
            #simple value
            logger.info("save descriptor and value")
            valuetype2 = keys2.include?("ValueType") ? data[key1]['ValueType'] : nil
            units2 = keys2.include?("Units") ? data[key1]['Units'] : nil            
            self.save_descriptor_and_value_v1(name2, valuetype2, value2, units2)            
          end

        #sometimes this is an array (array of hash - multiple descriptors to save)
        elsif innerdata.class.to_s === "Array"
          #2nd level: convert each array row to a hash
          innerdata.each do |d|
            temp = d.to_hash
            keys2 = temp.keys
            logger.info("2nd-level array element keys are: #{keys2.inspect}, size: #{keys2.size}")
            
            #get attributes
            value2 = keys2.include?("Value") ? d['Value'] : nil
            name2 = keys2.include?("Name") ? d['Name'] : nil
            #append name to nested_name to keep path (underscore separated)
            if !nested_name.nil? and nested_name != 'Report'
              name2 = nested_name + '_' + name2
            end           
            
            if keys2.include?("ValueType") and d['ValueType'] == 'AttributeVector'
              #send to processing
              logger.info("sending data to process_data function:  #{value2}")
              self.process_descriptor_data_v1(value2, name2)            
            else
              #simple value
              logger.info("save descriptor and value")
              valuetype2 = keys2.include?("ValueType") ? d['ValueType'] : nil
              units2 = keys2.include?("Units") ? d['Units'] : nil              
              self.save_descriptor_and_value_v1(name2, valuetype2, value2, units2)            
            end
          end  
          
        else
          #no more levels
          logger.info("no level2 info")
        end    
      end
    end

  end
  

  
end
