# Handles displaying of messages, table, cards, etc.
module Display
  include Currency

  def display_table
    system 'clear'
    puts Message.welcome
    puts Message::DIVIDER
    block_given? ? yield : display_shoe
    puts Message::DIVIDER
    display_dealers_hand
    display_players_hands
    puts Message::DIVIDER
  end

  def display_shuffling_deck
    cards = []
    15.times { display_cards_growing(cards) }
    15.times { display_cards_shrinking(cards) }
    15.times { display_cards_growing(cards) }
  end

  def display_player_count_request_message
    puts Message.player_count_request
  end

  def display_valid_player_count_message
    puts Message.valid_player_count
  end

  def display_move_message(player)
    puts Message.move(player)
  end

  def display_place_bet_message(player)
    puts Message.place_bet(player)
    print Wallet::CURRENCY
  end

  def display_invalid_bet_message(player, bet)
    puts Message.bet_too_low if bet < Rules::MIN_BET
    puts Message.wallet_too_low if player.wallet < bet
  end

  def display_play_again_message(player)
    puts Message.play_again(player)
  end

  def display_out_of_cash_message(player)
    puts Message.out_of_cash(player)
    sleep(3)
  end

  def display_table_closed_message
    puts Message.table_closed
  end

  private

  def display_cards_growing(cards)
    cards << Card::DOWN_CARD
    display_table { puts cards.join(' ') }
    sleep(0.05)
  end

  def display_cards_shrinking(cards)
    cards.pop
    display_table { puts cards.join(' ') }
    sleep(0.05)
  end

  def display_shoe
    shoe.low? ? display_low_card_count_message : display_shoe_cards
  end

  def display_shoe_cards
    shoe_cards = []
    15.times { shoe_cards << Card::DOWN_CARD }
    puts shoe_cards.join(' ')
  end

  def display_dealers_hand
    puts dealer.name
    puts "#{dealer.hand}"
    puts "#{total(dealer)} #{message(dealer)}"
    puts
  end

  def display_players_hands
    players.each do |player|
      puts "#{player.name} #{wallet(player)} #{bet(player)}"
      puts "#{player.hand}"
      puts "#{total(player)} #{message(player)}"
      puts
    end
  end

  def total(participant)
    "Total: #{participant.total}" unless participant.hand_empty?
  end

  def message(participant)
    "| #{participant.message}" if participant.message
  end

  def wallet(player)
    "| #{player.wallet}"
  end

  def bet(player)
    player.made_bet? ? "| Bet: #{format_as_currency(player.bet)}" : ''
  end

  def display_low_card_count_message
    puts Shoe::LOW_CARD_COUNT_MESSAGE
  end
end
