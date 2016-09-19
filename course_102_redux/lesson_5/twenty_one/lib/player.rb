# Has wallet
class Player < Participant
  attr_accessor :bet
  attr_reader :wallet

  def initialize
    super
    @wallet = Wallet.new
  end

  def set_name
    n = ''
    loop do
      Display.name_request_message
      n = gets.chomp
      break unless n.empty?
      Display.name_invalid_message
    end
    self.name = n
  end

  def reset_bet
    self.bet = nil
  end

  def made_bet?
    !bet.nil?
  end
end
