# Meta class
class Meta
  include Mongoid::Document

  # Fields
  field :name, type: String
  field :display_name, type: String
  field :description, type: String
  field :datatype, type: String
  field :units, type: String
  field :user_defined, type: Boolean

  #Validation
  validates_presence_of :name

  # Indexes
  index({ id: 1 }, unique: true)

end
