module Speak
  def speak(sound)
    puts sound
  end
end

class GoodDog
  include Speak
end

class Human
  include Speak
end

sparky = GoodDog.new
sparky.speak("Woof!")
joe = Human.new
joe.speak("Hiya!")