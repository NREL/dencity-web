class Descriptor
  include Mongoid::Document
  
  field :name, :type => String
  field :value_type, :type => String
  field :units, :type => String
  #field :category, :type => String  #handles flattening out nesting

  # Indexes
  index :name
  
  # Relationships
  references_many :edifices
  
  # Class Methods
  
end
