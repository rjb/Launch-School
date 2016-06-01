class GoodDog
  @@number_of_dogs = 0
  attr_accessor :name, :height, :weight

  def initialize(n, h, w)
    @name = n
    @height = h
    @weight = w
    @@number_of_dogs += 1
  end

  def change_info(n, h, w)
    self.name = n
    self.height = h
    self.weight = w
  end

  def speak
    "#{name} says arf!"
  end

  def info
    "#{name} weighs #{weight} and is #{height} tall."
  end

  def self.what_am_i
    "I'm a GoodDog class!"
  end

  def self.total_number_of_dogs
    @@number_of_dogs
  end
end

puts GoodDog.total_number_of_dogs

sparky = GoodDog.new('Sparky', '12 inches', '5 lbs.')
puts sparky.info

sparky.change_info('Spot', '24 inches', '10 lbs.')
puts sparky.info

jones = GoodDog.new('Sparky', '12 inches', '5 lbs.')
puts jones.info

sparky.change_info('Spot', '24 inches', '10 lbs.')
puts jones.info

puts GoodDog.total_number_of_dogs
