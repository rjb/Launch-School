module Loadable
  def can_carry_load?(weight)
    weight < 1000 ? true : false
  end
end

class Vehicle
  attr_accessor :color
  attr_reader :year, :model

  @@vehicle_count = 0

  def initialize(year, color, model)
    @@vehicle_count += 1
    @year = year
    @color = color
    @model = model
    @speed = 0
  end

  def speed_up
    @speed += 5
  end

  def break
    @speed -= 5 unless @speed == 0
  end

  def spray_paint(color)
    self.color = color
  end

  def current_speed
    puts "You are now going #{@speed} MPH"
  end

  def shut_off
    puts "Engine off"
  end

  def to_s
    "Year: #{self.year}; Mode: #{self.model}; Color: #{self.color}"
  end

  def self.miles_per_gallon(distance, gallons)
    distance / gallons
  end

  def self.vehicle_count
    @@vehicle_count
  end
end

class MyCar < Vehicle
  CABIN_TYPE = "Passenger"
end

class MyTruck < Vehicle
  include Loadable

  CABIN_TYPE = "Truck"
end

audi = MyCar.new(2005, 'gray', 'A4')

5.times { audi.speed_up }
audi.current_speed
10.times { audi.break }
audi.current_speed

audi.spray_paint('Black')
puts audi.color

mpg = MyCar.miles_per_gallon(30, 2)
puts "This car gets #{mpg} mpg"

puts audi
puts MyCar::vehicle_count

truck = MyTruck.new(2014, 'black', 'Toyota')
p truck.can_carry_load?(500)
