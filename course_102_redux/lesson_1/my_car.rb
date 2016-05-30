class MyCar
  attr_accessor :year, :color, :model, :speed

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end

  def speed_up
    self.speed += 5
  end

  def break
    self.speed -= 5 unless speed == 0
  end

  def shut_off
    puts "Engine off"
  end
end

audi = MyCar.new(2005, 'gray', 'A4')
puts audi.model

5.times { audi.speed_up }
puts audi.speed
10.times { audi.break }
puts audi.speed