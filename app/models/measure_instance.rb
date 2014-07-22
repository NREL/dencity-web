class MeasureInstance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :measure_uuid, type: String
  field :measure_vuid, type: String
  # dynamic argument fields stored in an "arguments" hash?
  field :arguments, type: Hash

  # Relations
  belongs_to :structure
  belongs_to :measure_description

end
