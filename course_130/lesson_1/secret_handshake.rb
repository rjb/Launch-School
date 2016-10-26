class SecretHandshake
  KEYS = ['wink', 'double blink', 'close your eyes', 'jump'].freeze

  def initialize(num)
    @binary = to_binary(num.to_i)
  end

  def commands
    result = KEYS.select.with_index { |key, idx| @binary.reverse[idx] == 1 }
    @binary.size == KEYS.size + 1 && @binary[-1] == 1 ? result.reverse : result
    # Or
    # @binary.reverse.each_with_object([]).with_index do |(value, result), idx|
      # next unless value == 1
      # idx < KEYS.size ? result << KEYS[idx] : result.reverse!
    # end
  end

  private

  def to_binary(num)
    result = []
    while num > 0
      result << num % 2
      num /=  2
    end
    result.reverse
  end
end

require 'minitest/autorun'

class SecretHandshakeTest < Minitest::Test
  def test_handshake_1_to_wink
    handshake = SecretHandshake.new(1)
    assert_equal ['wink'], handshake.commands
  end

  def test_handshake_10_to_double_blink
    handshake = SecretHandshake.new(2)
    assert_equal ['double blink'], handshake.commands
  end

  def test_handshake_100_to_close_your_eyes
    handshake = SecretHandshake.new(4)
    assert_equal ['close your eyes'], handshake.commands
  end

  def test_handshake_1000_to_jump
    handshake = SecretHandshake.new(8)
    assert_equal ['jump'], handshake.commands
  end

  def test_handshake_11_to_wink_and_double_blink
    handshake = SecretHandshake.new(3)
    assert_equal ['wink', 'double blink'], handshake.commands
  end

  def test_handshake_10011_to_double_blink_and_wink
    handshake = SecretHandshake.new(19)
    assert_equal ['double blink', 'wink'], handshake.commands
  end

  def test_handshake_11111_to_double_blink_and_wink
    handshake = SecretHandshake.new(31)
    expected = ['jump', 'close your eyes', 'double blink', 'wink']
    assert_equal expected, handshake.commands
  end

  def test_valid_string_input
    handshake = SecretHandshake.new('1')
    assert_equal ['wink'], handshake.commands
  end

  def test_invalid_handshake
    handshake = SecretHandshake.new('piggies')
    assert_equal [], handshake.commands
  end
end
