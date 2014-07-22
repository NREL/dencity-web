class Provenance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :category, type: String

  # Validation
  validates_presence_of :name, :category

  # Relations
  belongs_to :user
  has_many :structures

  CATEGORIES = ['sample_lhs', 'sample_sobol', 'sample_random']

end
