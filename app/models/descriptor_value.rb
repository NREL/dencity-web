class DescriptorValue
  include Mongoid::Document
  
  field :value,        :type => String
  
  # Indexes
  index :descriptor_id,  :unique => true

  # Relationships
  embedded_in :edifice

  
  # Class Methods  
  
end
