# Class for creating cards with any value
class Card
  DOWN_CARD = "\u{1F0A0}".freeze
  CUT_CARD = "\u{1F0DF}".freeze
  UP_STATE = 'up'.freeze
  DOWN_STATE = 'down'.freeze

  attr_reader :rank, :suit, :state

  def initialize(rank, suit, state = DOWN_STATE)
    @rank = rank
    @suit = suit
    @state = state
  end

  def to_s
    face_up? ? "#{rank}#{suit}" : DOWN_CARD
  end

  def flip
    @state = face_down? ? UP_STATE : DOWN_STATE
    self
  end

  def face_up?
    state == UP_STATE
  end

  def face_down?
    state == DOWN_STATE
  end

  def cut_card?
    suit == CUT_CARD
  end
end
