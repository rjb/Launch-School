# Contains all messages
class Message
  extend Currency

  def self.twenty_one
    'Twenty-One!'
  end

  def self.busted
    'Busted!'
  end

  def self.won(player)
    player.twenty_one? ? 'Twenty-One!' : 'Winner!'
  end

  def self.lost(player)
    player.busted? ? 'Busted!' : "You lost."
  end

  def self.draw
    'Draw.'
  end
end
