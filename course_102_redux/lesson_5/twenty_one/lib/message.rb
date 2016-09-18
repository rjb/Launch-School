# Contains all messages
class Message
  include Rules
  extend Currency

  DIVIDER = '-----------------------------'

  def self.welcome
    "Welcome to Twenty-One!\nTable minimum: #{format_as_currency(MIN_BET)}"
  end

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

  def self.place_bet(player)
    "#{player.name}: Place your bet."
  end

  def self.name_request
    'What is your name?'
  end

  def self.name_invalid
    'Invalid name.'
  end

  def self.player_count_request
    "How many players? (1-#{SEATS})"
  end

  def self.valid_player_count
    "Enter a valid number between 1 and #{SEATS}."
  end

  def self.bet_too_low
    'Bet is too low.' 
  end

  def self.wallet_too_low
    "You're wallet is a little light."
  end

  def self.move(player)
    "#{player.name}: Hit (h) or stand (s)?"
  end

  def self.play_again(player)
    "#{player.name}: Play another hand (enter) or cash out ($)?"
  end

  def self.out_of_cash(player)
    "#{player.name}: You're out of cash. Goodbye."
  end

  def self.table_closed
    'Table closed.'
  end
end
