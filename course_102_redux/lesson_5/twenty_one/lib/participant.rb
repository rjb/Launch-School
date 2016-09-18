# Parent class for player and dealer objects
class Participant
  attr_accessor :hand, :name, :message

  def initialize
    set_name
    clear_hand
  end

  def clear_hand
    @hand = Hand.new
  end

  def hit(card)
    hand << card
  end

  def total
    hand.total
  end

  def reset_message
    self.message = nil
  end

  def >(other)
    total > other.total
  end

  def ==(other)
    total == other.total
  end

  def hand_empty?
    hand.empty?
  end

  def twenty_one?
    hand.twenty_one? && hand.two_cards?
  end

  def busted?
    hand.busted?
  end
end
