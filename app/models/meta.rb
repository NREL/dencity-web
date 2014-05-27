# Meta class
class Meta
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String
  field :display_name, type: String
  field :description, type: String
  field :datatype, type: String
  field :user_defined, type: Boolean

  #Validation
  validates_presence_of :name

  # Indexes
  index({ id: 1 }, unique: true)

  belongs_to :unit

  def self.get_allowable_units
    Unit.where(allowable: true)
  end

end
