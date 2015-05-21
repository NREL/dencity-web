# Unit class
class Unit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :display_name, type: String
  field :type, type: String
  field :symbol, type: String
  field :symbol_alt, type: String
  field :allowable, type: Boolean

  field :mapped, type: Array # list of NREL specific units that mapped to this unit definition

  index({ name: 1 }, unique: true)
  index(mapped: 1)

  validates :name, uniqueness: true

  def self.get_unit_hash(name)
    unit = Unit.where(name: name).first
  end

  def name_and_symbol
    name + ' ( ' + symbol + ' )'
  end

  def self.get_types
    Unit.all.distinct(:type)
  end
end
