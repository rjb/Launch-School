# Standard deck of playing cards
class Deck
  RANKS = ('2'..'10').to_a + %w(J Q K A)
  SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"].freeze

  attr_accessor :cards

  def initialize
    @cards = []
    initialize_cards
  end

  def shuffle
    cards.shuffle!
  end

  def deal
    cards.shift
  end

  private

  def initialize_cards
    RANKS.product(SUITS).each { |value| cards << Card.new(*value) }
  end
end
