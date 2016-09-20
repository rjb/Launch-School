# Displaying of messages, table, and cards.
module Display
  include Currency

  DIVIDER = '-----------------------------'.freeze

  def display_table
    system 'clear'
    puts "Welcome to Twenty-One!\n" \
         "Table minimum: #{format_as_currency(Rules::MIN_BET)}"
    puts DIVIDER
    block_given? ? yield : display_shoe
    puts DIVIDER
    display_dealers_hand
    display_players_hands
    puts DIVIDER
  end

  def display_shuffling_deck
    cards = []
    15.times { display_cards_growing(cards) }
    15.times { display_cards_shrinking(cards) }
    15.times { display_cards_growing(cards) }
  end

  def display_player_count_request_message
    puts "How many players? (1-#{Rules::SEATS})"
  end

  def display_valid_player_count_message
    puts "Enter a valid number between 1 and #{Rules::SEATS}."
  end

  def display_move_message(player)
    puts "#{player.name}: Hit (h) or stand (s)?"
  end

  def display_place_bet_message(player)
    puts "#{player.name}: Place your bet."
    print Wallet::CURRENCY
  end

  def display_invalid_bet_message(player, bet)
    puts 'Bet is too low.' if bet < Rules::MIN_BET
    puts "You're wallet is a little light." if player.wallet < bet
  end

  def display_play_again_message(player)
    puts "#{player.name}: Play another hand (enter) or cash out ($)?"
  end

  def display_out_of_cash_message(player)
    puts "#{player.name}: You're out of cash. Goodbye."
    sleep(3)
  end

  def display_table_closed_message
    puts 'Table closed.'
  end

  def twenty_one_message
    'Twenty-One!'
  end

  def busted_message
    'Busted!'
  end

  def won_message(player)
    player.twenty_one? ? 'Twenty-One!' : 'Winner!'
  end

  def lost_message(player)
    player.busted? ? 'Busted!' : 'You lost.'
  end

  def draw_message
    'Draw.'
  end

  def self.name_request_message
    puts 'What is your name?'
  end

  def self.name_invalid_message
    puts 'Invalid name.'
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
    puts dealer.hand.to_s
    puts "#{total(dealer)} #{message(dealer)}"
    puts
  end

  def display_players_hands
    players.each do |player|
      puts "#{player.name} #{wallet(player)} #{bet(player)}"
      puts player.hand.to_s
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
