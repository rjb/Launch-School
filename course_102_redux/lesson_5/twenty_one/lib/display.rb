# Handles displaying of messages, table, cards, etc.
class Display
  def self.name_request_message
    puts Message.name_request
  end

  def self.name_invalid_message
    puts Message.name_invalid
  end

  def self.player_count_request_message
    puts Message.player_count_request
  end

  def self.valid_player_count_message
    puts Message.valid_player_count
  end

  def self.move_message(player)
    puts Message.move(player)
  end

  def self.place_bet_message(player)
    puts Message.place_bet(player)
    print Wallet::CURRENCY
  end

  def self.invalid_bet_message(player, bet)
    puts Message.bet_too_low if bet < Rules::MIN_BET
    puts Message.wallet_too_low if player.wallet < bet
  end

  def self.play_again_message(player)
    puts Message.play_again(player)
  end

  def self.out_of_cash_message(player)
    puts Message.out_of_cash(player)
    sleep(3)
  end

  def self.low_card_count_message
    puts Shoe::LOW_CARD_COUNT_MESSAGE
  end

  def self.table_closed_message
    puts Message.table_closed
  end
end
