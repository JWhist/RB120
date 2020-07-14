class MyCar
  
  attr_accessor :color
  attr_reader :year, :model

  def self.mpg(miles, gallons)
    puts "MPG: #{miles/gallons}"
  end

  def initialize(year, model, color)
    @year = year
    @model = model
    @color = color
    @speed = 0
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

end

camry = MyCar.new(2014, "Toyota", "Black")

camry.current
camry.accel(30)
camry.current
camry.brake(10)
camry.current
camry.stop
camry.current
camry.color = "Yellow"
p camry.color
camry.year 
camry.spray_paint
p camry.color