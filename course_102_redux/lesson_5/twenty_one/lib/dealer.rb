# Deals cards from shoe
class Dealer < Participant
  HIT_MINIMUM = 17
  NAMES = [
    'HAL',
    'C-3PO',
    'Number5',
    'GERTY',
    'RobotB-9',
    'Rosie'
  ].freeze

  def set_name
    self.name = NAMES.sample
  end

  def deal(shoe, flip = true)
    flip ? shoe.deal.flip : shoe.deal
  end

  def reveal_hand
    hand.reveal
  end
end
