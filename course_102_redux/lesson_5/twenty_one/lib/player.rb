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
      puts Message.name_request
      n = gets.chomp
      break unless n.empty?
      puts Message.name_invalid
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
