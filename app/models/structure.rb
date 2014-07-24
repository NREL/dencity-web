# Structure class
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :other_field, type: String

  # Relations
  belongs_to :user
  #belongs_to :provenance

end
