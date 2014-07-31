class MeasureDescription
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :uuid, type: String
  field :version_id, type: String
  field :display_name, type: String
  field :type, type: String
  field :default_value, type: String
  field :description, type: String
  field :modeler_description, type: String
  field :arguments, type: Array

  # Relations
  has_many :measure_instances

  # Validations
  validates :version_id, :uniqueness => { :scope => :uuid }

end
