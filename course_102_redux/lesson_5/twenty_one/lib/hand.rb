# A collection of cards given to a participant
class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end

  def <<(card)
    cards << card
  end

  def total
    result = ranks.map { |rank| value(rank) }.reduce(&:+)
    ranks.count('A').times { result -= 10 if result > 21 }
    result
  end

  def reveal
    cards.each { |card| card.flip if card.face_down? }
  end

  def count
    cards.count
  end

  def to_s
    cards.map(&:to_s).join(' ')
  end

  def twenty_one?
    total == 21
  end

  def busted?
    total > 21
  end

  def two_cards?
    count == 2
  end

  def empty?
    count.zero?
  end

  private

  def ranks
    cards.select(&:face_up?).map(&:rank)
  end

  def value(rank)
    if rank == 'A'
      11
    elsif %w(J K Q).include?(rank)
      10
    else
      rank.to_i
    end
  end
end
