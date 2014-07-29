class MeasureInstance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :uuid, type: String
  field :version_id, type: String
  field :index, type: Integer
  field :uri, type: String
  field :arguments, type: Hash

  # Relations
  belongs_to :structure
  belongs_to :measure_description

end
