# Structure class
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :user
  belongs_to :provenance

end
