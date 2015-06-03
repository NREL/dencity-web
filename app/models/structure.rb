# Structure class
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongo

  # Fields
  field :user_defined_id, type: String

  # Specific metadata objects that we want to have searchable
  field :building_type, type: String
  field :building_area
  field :total_building_volume
  field :total_source_eui
  field :total_site_eui

  embeds_many :related_files

  # Relations
  belongs_to :user
  belongs_to :provenance
  has_many :measure_instances

  # Validations
  # validates :user_defined_id, uniqueness: { scope: :user_id }
  validates_uniqueness_of :user_defined_id, scope: :user_id

  # Add indexes for most popular fields
  index(building_type: 1, building_area: 1)
  index(user_id: 1)

  # Searching
  searchable do
    string(:type) { self.class.name }

    text :id

    # text :building_type, stored: true
    double :building_area, stored: true
    double :total_source_eui, stored: true
    double :total_site_eui, stored: true

    time :updated_at
    time :created_at
    # string(:name_string) { name } # For sorting
  end

  before_validation :assign_id

  protected

  def assign_id
    self.user_defined_id = id if user_defined_id.nil?
  end
end
