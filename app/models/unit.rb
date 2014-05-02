# Meta class
class Unit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :machine_name, :type => String
  field :type, :type => String
  field :symbol, :type => String
  field :symbol_alt, :type => String

  field :mapped, :type => Array #list of NREL specific units that mapped to this unit definition

  index( { :machine_name => 1}, :unique => true)
  index( { :mapped => 1} )

  validates :machine_name, :uniqueness => true

  def self.get_unit_hash(machine_name)

    unit = Unit.where(:machine_name => machine_name).first

  end
end
