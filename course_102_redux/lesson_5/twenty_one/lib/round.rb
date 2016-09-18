class Round
  include Currency

  attr_reader :players, :dealer, :shoe

  def initialize(dealer, players, shoe)
    @dealer = dealer
    @players = players
    @shoe = shoe
  end

  def play
    place_bets
    deal_initial_cards
  end

  def place_bets
    players.each do |player|
      place_bet(player)
      withdraw_bet(player)
    end
  end

  def place_bet(player)
    bet = nil
    loop do
      puts "#{player.name}: Place your bet."
      print Wallet::CURRENCY
      bet = gets.chomp.to_f
      break if valid_bet?(player, bet)
      display_invalid_bet_message(player, bet)
    end
    player.bet = bet
  end

  def withdraw_bet(player)
    player.wallet.withdraw(player.bet)
  end

  def deal_initial_cards
    2.times do
      players.each { |player| deal_card(player) }
      deal_card(dealer, dealer.hand_empty?)
    end
  end

  def deal_card(participant, flip = false)
    card = dealer.deal(shoe)
    card.flip if flip
    participant.hit(card)
    sleep(0.5)
    display_table
  end

  def valid_bet?(player, bet)
    bet >= Rules::MIN_BET && player.wallet >= bet
  end

  def display_invalid_bet_message(player, bet)
    puts 'Bet is too low.' if bet < Rules::MIN_BET
    puts "You're wallet is a little light." if player.wallet < bet
  end

  def display_table
    system 'clear'
    # puts game_message
    puts '-----------------------------'
    block_given? ? yield : display_shoe
    puts '-----------------------------'
    show_dealers_hand
    show_players_hands
    puts '-----------------------------'
  end

  def display_shoe
    shoe.low? ? display_low_card_count_message : display_shoe_cards
  end

  def show_dealers_hand
    puts dealer.name
    puts "#{dealer.hand}"
    puts "#{show_total(dealer)} #{show_message(dealer)}"
    puts
  end

  def show_players_hands
    players.each do |player|
      puts "#{player.name} #{show_wallet(player)} #{show_bet(player)}"
      puts "#{player.hand}"
      puts "#{show_total(player)} #{show_message(player)}"
      puts
    end
  end

  def display_shoe_cards
    shoe_cards = []
    15.times { shoe_cards << Card::DOWN_CARD }
    puts shoe_cards.join(' ')
  end

  def show_total(participant)
    "Total: #{participant.total}" unless participant.hand_empty?
  end

  def show_message(participant)
    "| #{participant.message}" if participant.message
  end

  def show_wallet(player)
    "| #{player.wallet}"
  end

  def show_bet(player)
    player.made_bet? ? "| Bet: #{format_as_currency(player.bet)}" : ''
  end
end
