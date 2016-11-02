class Clock
  attr_reader :minutes

  def initialize(hrs, mins = 0)
    @minutes = ((hrs == 0 ? 24 : hrs) * 60) + mins
  end

  def self.at(hrs, mins = 0)
    new(hrs, mins)
  end

  def to_s
    hrs = (minutes / 60) - (((minutes / 60) / 24) * 24)
    mins = minutes % 60
    format('%02d:%02d', hrs, mins)
  end

  def +(num)
    @minutes += num
    self
  end

  def -(num)
    @minutes -= num
    self
  end

  def ==(other)
    minutes == other.minutes
  end
end

require 'minitest/autorun'

class ClockTest < Minitest::Test
  def test_on_the_hour
    assert_equal '08:00', Clock.at(8).to_s
    assert_equal '09:00', Clock.at(9).to_s
  end

  def test_past_the_hour
    assert_equal '11:09', Clock.at(11, 9).to_s
  end

  def test_add_a_few_minutes
    clock = Clock.at(10) + 3
    assert_equal '10:03', clock.to_s
  end

  def test_add_over_an_hour
    clock = Clock.at(10) + 61
    assert_equal '11:01', clock.to_s
  end

  def test_wrap_around_at_midnight
    clock = Clock.at(23, 30) + 60
    assert_equal '00:30', clock.to_s
  end

  def test_subtract_minutes
    clock = Clock.at(10) - 90
    assert_equal '08:30', clock.to_s
  end

  def test_equivalent_clocks
    clock1 = Clock.at(15, 37)
    clock2 = Clock.at(15, 37)
    assert_equal clock1, clock2
  end

  def test_inequivalent_clocks
    clock1 = Clock.at(15, 37)
    clock2 = Clock.at(15, 36)
    clock3 = Clock.at(14, 37)
    refute_equal clock1, clock2
    refute_equal clock1, clock3
  end

  def test_wrap_around_backwards
    clock = Clock.at(0, 30) - 60
    assert_equal '23:30', clock.to_s
  end
end
