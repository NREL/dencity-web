class Edifice
  include Mongoid::Document
  
  field :name,    :type => String
  
  # Indexes
  index :name,    :unique => true
  
  # Relationships
  referenced_in :descriptor
  embeds_many :descriptor_values
  accepts_nested_attributes_for :descriptor_values
  
end
