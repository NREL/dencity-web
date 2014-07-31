# Structure class
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :user_defined_id, type: String

  # Relations
  belongs_to :user
  has_many :attachments
  belongs_to :provenance
  has_many :measure_instances

  # Validations
 # validates :user_defined_id, uniqueness: { scope: :user_id }
  validates_uniqueness_of :user_defined_id, scope: :user_id


  before_validation :assign_id

  protected

    def assign_id
      if self.user_defined_id.nil?
        self.user_defined_id = self.id
      end
    end

end
