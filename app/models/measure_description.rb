class MeasureDescription
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :uuid, type: String
  field :description, type: String

  # Relations
  has_many :measure_instances

end
