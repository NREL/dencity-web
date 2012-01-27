class Edifice
  include Mongoid::Document
  
  field :name,    :type => String
  
  # Indexes
  index :name,    :unique => true
  
  # Relationships
  referenced_in :descriptor
  referenced_in :user
  embeds_many :descriptor_values
  accepts_nested_attributes_for :descriptor_values
  
  #Class Methods
  def save_descriptor_and_value(name, valuetype, value, units, category=nil)
    
    #create/update descriptor (use category name if provided)
    if category == "Report"
      category = nil
    end
    descriptor = category.nil? ? Descriptor.find_or_create_by(:name => name) : Descriptor.find_or_create_by(:name => name, :category => category)
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
    #logger.info("descriptor saved, id is #{descriptor._id}")

    #save value           
    self.descriptor_values.find_or_create_by(:descriptor_id => descriptor._id)
    self.set_value_from_descriptor_id(descriptor._id, value)
              
  end
  
  def process_descriptor_data(data, category_name=nil)
    #takes a snippet of xml-parsed data, in hash / array format
    
    #parse variables
    valuetype2 = nil
    units2 = nil
    value2 = nil
    name2 = nil
    
    thekeys = data.keys
    
    logger.info("HEY keys are: #{thekeys.inspect}, size: #{thekeys.size}, class: #{data.class}")

    #should have Attribute keys only here?
    thekeys.each do |key1|
      if key1 == "Attribute"
        #get inner data and process
        innerdata = data[key1]
        logger.info("class:#{innerdata.class}")
        
        #sometimes this is a hash? (only 1 descriptor)
        if innerdata.class.to_s === "Hash"
          #2nd level
          keys2 = innerdata.keys
          logger.info("2nd-level keys are: #{keys2.inspect}, size: #{keys2.size}")
          if keys2.include?("ValueType") and data[key1]['ValueType'] == 'AttributeVector'
            #send to processing
            value2 = keys2.include?("Value") ? data[key1]['Value'] : nil
            name2 = keys2.include?("Name") ? data[key1]['Name'] : nil
            logger.info("sending data to process_data function:  #{value2}")
            #append name to category_name to keep path (comma separated)
            if !category_name.nil? and category_name != 'Report'
              name2 = category_name + ', ' + name2
            end
            self.process_descriptor_data(value2, name2)            
          else
            #simple value
            logger.info("save descriptor and value")
            valueType2 = keys2.include?("ValueType") ? data[key1]['ValueType'] : nil
            value2 = keys2.include?("Value") ? data[key1]['Value'] : nil
            name2 = keys2.include?("Name") ? data[key1]['Name'] : nil
            units2 = keys2.include?("Units") ? data[key1]['Units'] : nil            
            self.save_descriptor_and_value(name2, valuetype2, value2, units2, category_name)            
          end

        #sometimes this is an array (array of hash - multiple descriptors to save)
        elsif innerdata.class.to_s === "Array"
          #2nd level: convert each array row to a hash
          innerdata.each do |d|
            temp = d.to_hash
            keys2 = temp.keys
            logger.info("2nd-level array element keys are: #{keys2.inspect}, size: #{keys2.size}")
            
            if keys2.include?("ValueType") and d['ValueType'] == 'AttributeVector'
              #send to processing
              value2 = keys2.include?("Value") ? d['Value'] : nil
              name2 = keys2.include?("Name") ? d['Name'] : nil
              logger.info("sending data to process_data function:  #{value2}")
              #append name to category_name to keep path (comma separated)
              if !category_name.nil? and category_name != 'Report'
                name2 = category_name + ', ' + name2
              end
              self.process_descriptor_data(value2, name2)            
            else
              #simple value
              logger.info("save descriptor and value")
              valueType2 = keys2.include?("ValueType") ? d['ValueType'] : nil
              value2 = keys2.include?("Value") ? d['Value'] : nil
              name2 = keys2.include?("Name") ? d['Name'] : nil
              units2 = keys2.include?("Units") ? d['Units'] : nil              
              self.save_descriptor_and_value(name2, valuetype2, value2, units2, category_name)            
            end
          end  
          
        else
          #no more levels?
          logger.info("no level2 info")
        end    
      end
    end

  end
  
  def get_value_from_descriptor_id(descriptor_id)
    ret = nil
    self.descriptor_values.each do |dv|
      if dv.descriptor_id == descriptor_id
        ret = dv[:value]
        return ret
      end
    end
    
  end
  
  def set_value_from_descriptor_id(descriptor_id, value)
    self.descriptor_values.each do |dv|
      if dv.descriptor_id == descriptor_id
        dv[:value] = value
        dv.save!
      end
    end
    self.save!
  end
  
end
