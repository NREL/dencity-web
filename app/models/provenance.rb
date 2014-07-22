class Provenance
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :analysis_name, type: String
  field :category, type: String

  # Validation
  validates_presence_of :analysis_name, :category

  # Relations
  belongs_to :user
  has_many :structures

  def self.get_categories
    categories = ['sample_lhs', 'sample_sobol', 'sample_random']
  end
end
