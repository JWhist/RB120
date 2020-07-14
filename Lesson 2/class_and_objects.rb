class Person
  attr_accessor :first_name, :last_name
  
  def initialize(name)
    parse_full_name(name)
  end

  def name
    "#{@first_name} #{last_name}".strip
  end

  def name=(name)
    parse_full_name(name)
  end

  def to_s
    name
  end
  
  private

  def parse_full_name(name)
    self.first_name = name.split[0]
    self.last_name = name.split[1] || ''
  end

end

bob = Person.new('Robert Smith')
puts "The person's name is: #{bob}"