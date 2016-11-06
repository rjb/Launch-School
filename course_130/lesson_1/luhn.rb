class Luhn
  attr_accessor :number

  def initialize(num)
    @number = num.to_s.split('').map(&:to_i)
  end

  def addends
    number.reverse.map.with_index do |element, idx|
      element *= 2 unless idx % 2 == 0
      element >= 10 ? element -= 9 : element
    end.reverse
  end

  def checksum
    addends.reduce(&:+)
  end

  def valid?
    checksum % 10 == 0
  end

  def self.create(num)
    luhn = Luhn.new(num)
    luhn.number << 0
    luhn.number[-1] = (10 - luhn.checksum % 10) unless luhn.valid?
    luhn.number.join.to_i
  end
end

require 'minitest/autorun'

class LuhnTest < Minitest::Test
  def test_addends
    luhn = Luhn.new(12_121)
    assert_equal [1, 4, 1, 4, 1], luhn.addends
  end

  def test_too_large_addend
    luhn = Luhn.new(8631)
    assert_equal [7, 6, 6, 1], luhn.addends
  end

  def test_checksum
    luhn = Luhn.new(4913)
    assert_equal 22, luhn.checksum
  end

  def test_checksum_again
    luhn = Luhn.new(201_773)
    assert_equal 21, luhn.checksum
  end

  def test_invalid_number
    luhn = Luhn.new(738)
    refute luhn.valid?
  end

  def test_valid_number
    luhn = Luhn.new(8_739_567)
    assert luhn.valid?
  end

  def test_create_valid_number
    number = Luhn.create(123)
    assert_equal 1230, number
  end

  def test_create_other_valid_number
    number = Luhn.create(873_956)
    assert_equal 8_739_567, number
  end

  def test_create_yet_another_valid_number
    number = Luhn.create(837_263_756)
    assert_equal 8_372_637_564, number
  end
end
