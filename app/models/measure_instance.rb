# MeasureInstance class
class MeasureInstance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :uuid, type: String
  field :version_id, type: String
  field :uri, type: String
  field :arguments, type: Hash

  # Relations
  belongs_to :structure, index: true
  belongs_to :measure_description
end
