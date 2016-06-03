module Swimmable
  def swim
    "I'm swimming"
  end
end

class Animal
end

class Mammal < Animal
end

class Fish < Animal
  include Swimmable
end

class Dog < Mammal
  include Swimmable
end

class Cat < Mammal
end

goldie = Fish.new
sparky = Dog.new
paws = Cat.new

puts goldie.swim
puts sparky.swim
puts paws.swim
