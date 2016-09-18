# Holds decks of cards from which cards are dealt
class Shoe
  DECK_COUNT = 4
  LOW_CARD_COUNT_MESSAGE = 'Low on cards. Last hand before shuffle.'.freeze

  attr_reader :cards, :cut_spot

  def initialize
    @cards = []
  end

  def reset
    cards.clear
    load_cards
    shuffle_cards
    place_cut_card
  end

  def shuffle_cards
    cards.shuffle!
  end

  def place_cut_card
    @cut_spot = random_spot
  end

  def deal
    cards.shift
  end

  def low?
    cards.empty? || cut_card_hit?
  end

  private

  def load_cards
    DECK_COUNT.times { @cards.concat(Deck.new.cards) }
  end

  def random_spot
    (size * rand(0.15..0.25)).to_i
  end

  def size
    cards.length
  end

  def cut_card_hit?
    size <= cut_spot
  end
end
