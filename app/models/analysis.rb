# Analysis class
class Analysis
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :display_name, type: String
  field :description, type: String
  field :user_defined_id, type: String
  field :user_created_date, type: DateTime
  field :analysis_types, type: Array
  field :analysis_information, type: Hash

  # count number of structures
  field :structures_count, type: Integer, default: 0

  # Validation
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :user_id

  # Relations
  belongs_to :user
  has_many :structures
end
