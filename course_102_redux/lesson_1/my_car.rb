class MyCar
  attr_accessor :color
  attr_reader :year

  def initialize(year, color, model)
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
end

audi = MyCar.new(2005, 'gray', 'A4')

5.times { audi.speed_up }
audi.current_speed
10.times { audi.break }
audi.current_speed

audi.spray_paint('Black')
puts audi.color
