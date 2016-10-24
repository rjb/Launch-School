class PerfectNumber
  def self.classify(num)
    raise RuntimeError if num < 2
    result = (1...num).select { |n| n if num % n == 0 }.reduce(&:+)
    case
      when result < num then 'deficient'
      when result > num then 'abundant'
      when result == num then 'perfect'
    end
  end
end

require 'minitest/autorun'

class PerfectNumberTest < Minitest::Test
  def test_initialize_perfect_number
    assert_raises RuntimeError do
      PerfectNumber.classify(-1)
    end
  end

  def test_classify_deficient
    assert_equal 'deficient', PerfectNumber.classify(13)
  end

  def test_classify_perfect
    assert_equal 'perfect', PerfectNumber.classify(28)
  end

  def test_classify_abundant
    assert_equal 'abundant', PerfectNumber.classify(12)
  end
end
