# Used to hold and keep track of player's money
class Wallet
  include Currency

  CURRENCY = CURRENCIES['US']
  DEFAULT_VALUE = 100

  attr_accessor :value

  def initialize(value = DEFAULT_VALUE)
    @value = value
  end

  def deposit(amount)
    self.value += amount
  end

  def withdraw(amount)
    self.value -= amount unless amount > value
  end

  def <(other)
    value < other
  end

  def >=(other)
    value >= other
  end

  def to_s
    format_as_currency(value)
  end

  def empty?
    value.zero?
  end
end
