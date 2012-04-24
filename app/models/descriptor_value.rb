class DescriptorValue
  include Mongoid::Document
  
  field :value
  
  # Indexes
  index :descriptor_id,  :unique => true

  # Relationships
  embedded_in :edifice

  # Class Methods  
end
