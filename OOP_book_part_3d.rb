module Kidable
  def child_safe?(age)
    age > 8
  end
end

class Vehicle
  
  @@num_of_vehicles = 0

  attr_accessor :color
  attr_reader :year, :model

  def initialize(year, model, color)
    @year = year
    @model = model
    @color = color
    @speed = 0
    @@num_of_vehicles += 1
  end

  def accel(num)
    @speed += num
    puts "Speed increased by #{num} mph.  It is now #{@speed} mph."
  end

  def brake(num)
    @speed -= num
    puts "Speed decreased by #{num} mph.  It is now #{@speed} mph."
  end

  def stop
    @speed = 0
    puts "Vehicle stopped.  The speed is now #{@speed} mph."
  end

  def current
    puts "The current speed is #{@speed} mph."
  end

  def spray_paint
    puts "What color do you want to paint the car?"
    self.color = gets.chomp
    puts "Excellent choice!  The #{@model} is now painted #{@color.downcase}."
  end

  def to_s
    puts "This is a #{color} #{year} #{model}."
  end
  
  def self.mpg(miles, gallons)
    puts "MPG: #{miles/gallons}"
  end

  def self.total
    puts "There are #{@@num_of_vehicles} vehicles."
  end

  def age
    "Your #{self.model} is #{years_old} years old."
  end

  private

  def years_old
    Time.now.year - self.year
  end



end

class MyCar < Vehicle
  include Kidable
  DOORS = 4
end

class Truck < Vehicle
  DOORS = 2
end

camry = MyCar.new(2012, "toyota", "camry")
camry.to_s

Vehicle.total

bronco = Truck.new(2000, "chevy", 's-10')
bronco.to_s

Vehicle.total
bronco.accel(30)
bronco.stop

p camry.child_safe?(10)

puts camry.age