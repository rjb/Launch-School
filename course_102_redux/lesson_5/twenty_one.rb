module Currency
  CURRENCIES = {
    'US' => '$',
    'UK' => '£',
    'EU' => '€',
    'JP' => '¥'
  }

  def format_as_currency(amount)
    "#{Wallet::CURRENCY}%.2f" % amount
  end
end

class Wallet
  include Currency

  CURRENCY = CURRENCIES['US']
  DEFAULT_VALUE = 100

  attr_accessor :value

  def initialize(value = DEFAULT_VALUE)
    @value = value
  end

  def deposit(amount)
    self.value += amount
  end

  def withdraw(amount)
    self.value -= amount unless amount > value
  end

  def <(amount)
    value < amount
  end

  def >=(amount)
    value >= amount
  end

  def to_s
    format_as_currency(value)
  end

  def empty?
    value == 0
  end
end

class Participant
  attr_accessor :hand, :name, :message

  def initialize
    set_name
    clear_hand
  end

  def clear_hand
    @hand = Hand.new
  end

  def hit(card)
    self.hand << card
  end

  def total
    hand.total
  end

  def >(other_participant)
    total > other_participant.total
  end

  def ==(other_participant)
    total == other_participant.total
  end

  def hand_empty?
    hand.empty?
  end

  def twenty_one?
    hand.twenty_one? && hand.two_cards?
  end

  def busted?
    hand.busted?
  end
end

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
      puts 'What is your name?'
      n = gets.chomp
      break unless n.empty?
      puts 'Invalid name.'
    end
    self.name = n
  end

  def reset_bet
    self.bet = nil
  end

  def made_bet?
    !!bet
  end
end

class Dealer < Participant
  HIT_MINIMUM = 17
  NAMES = [
    'HAL',
    'C-3PO',
    'Number5',
    'GERTY',
    'RobotB-9',
    'Rosie'
  ]

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

class Shoe
  DECK_COUNT = 4

  attr_reader :cards

  def initialize
    @cards = []
    initialize_cards
  end

  def shuffle
    cards.shuffle!
  end

  def place_cut_card
    @cards.insert(random_spot, Card.new(Card::CUT_CARD))
  end

  def deal
    cards.shift
  end

  private

  def initialize_cards
    DECK_COUNT.times { @cards.push(*Deck.new.cards) }
  end

  def random_spot
    -(size * rand(0.10..0.25))
  end

  def size
    cards.length
  end
end

class Deck
  SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"]
  RANKS = ('2'..'10').to_a + %w(J Q K A)

  attr_accessor :cards

  def initialize
    @cards = []
    initialize_cards
  end

  def shuffle
    cards.shuffle!
  end

  def deal
    cards.shift
  end

  private

  def initialize_cards
    RANKS.product(SUITS).each { |value| cards << Card.new(value) }
  end
end

class Card
  DOWN_CARD = "\u{1F0A0}"
  CUT_CARD = "\u{1F0DF}"
  UP_STATE = 'up'
  DOWN_STATE = 'down'

  attr_accessor :value
  attr_reader :state

  def initialize(value, state = DOWN_STATE)
    @value = value
    @state = state
  end

  def to_s
    face_up? ? value.join('') : DOWN_CARD
  end

  def flip
    @state = face_down? ? UP_STATE : DOWN_STATE
    self
  end

  def face_up?
    state == UP_STATE
  end

  def face_down?
    state == DOWN_STATE
  end

  def cut_card?
    value == CUT_CARD
  end
end

class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end

  def <<(card)
    self.cards << card
  end

  def total
    hand_total = 0
    values = cards.select(&:face_up?).map { |card| card.value[0] }

    values.each do |value|
      if value == 'A'
        hand_total += 11
      elsif %w(J K Q).include?(value)
        hand_total += 10
      else
        hand_total += value.to_i
      end
    end

    values.count('A').times do
      hand_total -= 10 if hand_total > 21
    end

    hand_total
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
    count == 0
  end
end

class Table
  SEATS = 5
end

class Game
  include Currency

  MIN_BET = 1
  STANDARD_PAYOUT = 1/1
  TWENTY_ONE_PAYOUT = 3.0/2.0
  CUT_CARD_MESSAGE = 'Cut card. Last hand before shuffle.'

  attr_reader :players, :shoe, :dealer

  def initialize
    @players = []
    @dealer = Dealer.new
    initialize_players
  end

  def get_player_count
    count = nil
    loop do
      puts "How many players? (1-#{Table::SEATS})"
      count = gets.chomp.to_i
      break if (1..Table::SEATS).include?(count)
      puts "Enter a valid number, between 1 and #{Table::SEATS}."
    end
    count
  end

  def start
    reset_shoe

    loop do
      initialize_table
      place_bets

      deal_initial_cards
      twenty_one?
      players_turns
      dealers_turn
      award_winners
      show_results
      boot_broke_players
      cash_out_players

      break if table_empty?
      reset_shoe if shoe_nearly_empty?
    end

    close_table
  end

  private

  def initialize_table
    reset_messages
    reset_bets
    clear_table
  end

  def reset_bets
    players.each { |player| player.reset_bet }
  end

  def reset_messages
    players.each { |player| player.message = nil }
    dealer.message = nil
  end

  def table_empty?
    players.empty?
  end

  def initialize_players
    count = get_player_count
    count.times do |i|
      print "Player #{i + 1}: "
      @players << Player.new
    end
  end

  def reset_shoe
    @shoe = Shoe.new
    @cut_card_message = nil
    shuffle_deck
    shoe.place_cut_card
    display_table
  end

  def display_message(msg)
    puts msg
    sleep(3)
    display_table
  end

  def display_shuffling_deck
    cards = []
    15.times { display_cards_spreading(cards) }
    15.times { display_cards_shuffling(cards) }
    15.times { display_cards_spreading(cards) }
  end

  def display_cards_spreading(cards)
    cards << Card::DOWN_CARD
    display_table { puts cards.join(' ') }
    sleep(0.05)
  end

  def display_cards_shuffling(cards)
    cards.pop
    display_table { puts cards.join(' ') }
    sleep(0.05)
  end

  def display_shoe
    display_cut_card_message
    display_shoe_cards unless @cut_card_message
  end

  def display_shoe_cards
    shoe_cards = []
    15.times { shoe_cards << Card::DOWN_CARD }
    puts shoe_cards.join(' ')
  end

  def display_table
    system 'clear'
    display_game_message
    puts '-----------------------------'
    block_given? ? yield : display_shoe
    puts '-----------------------------'
    show_dealers_hand
    show_players_hands
    puts '-----------------------------'
  end

  def display_cut_card_message
    puts @cut_card_message if @cut_card_message
  end

  def display_cash_out_message
    if wallet_empty?
      puts "You're out of cash."
    else
      puts "Here's your #{human.wallet}"
    end
  end

  def display_goodbye_message
    puts 'Goodbye!'
  end

  # Table should show bet amount deducted from wallet after player submits amount
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

  def display_invalid_bet_message(player, bet)
    puts 'Bet is too low.' if bet < MIN_BET
    puts "You're wallet is a little light." if player.wallet < bet
  end

  def display_game_message
    puts "Welcome to Twenty-One!\nTable minimum: #{format_as_currency(MIN_BET)}"
  end

  def reveal_dealers_hand
    dealer.reveal_hand
    display_table
  end

  def show_dealers_hand
    puts "#{dealer.name}"
    puts "#{dealer.hand} #{dealer.message}"
    puts
  end

  def show_players_hands
    players.each do |player|
      puts "#{player.name} #{show_wallet(player)} #{show_bet(player)}"
      puts "#{show_total(player)} #{player.hand} #{player.message}"
      puts
    end
  end

  def show_total(player)
    unless player.hand_empty?
      "(#{player.total})"
    end
  end

  def show_wallet(player)
    "| #{player.wallet}"
  end

  def show_bet(player)
    player.made_bet? ? "| Bet: #{format_as_currency(player.bet)}" : ''
  end

  def shuffle_deck
    shoe.shuffle
    display_shuffling_deck
  end

  def clear_table
    clear_players_hands
    clear_dealers_hand
    display_table
  end

  def clear_players_hands
    players.each { |player| player.clear_hand }
  end

  def clear_dealers_hand
    dealer.clear_hand
  end

  def active_players
    players.select { |p| !p.twenty_one? }
  end

  def players_turns
    active_players.each do |player|
      loop do
        puts "#{player.name}: Hit (h) or stand (s)?"
        break unless gets.chomp.downcase == 'h'
        deal_card(player)
        if player.busted?
          player.message = 'Busted!'
          display_table
          break
        end
      end
    end
  end

  def all_twenty_one?
    players.all?(&:twenty_one?)
  end

  def all_busted?
    players.all?(&:busted?)
  end

  def dealers_turn
    reveal_dealers_hand
    unless all_twenty_one? || all_busted?
      while dealer.total < Dealer::HIT_MINIMUM
        deal_card(dealer)
      end
      if dealer.busted?
        dealer.message = 'Busted!'
        display_table
      end
    end
  end

  def deal_initial_cards
    2.times do
      players.each { |player| deal_card(player) }
      deal_card(dealer, dealer.hand_empty?)
    end
  end

  def deal_card(player, flip = false)
    card = next_card
    card.flip if flip
    player.hit(card)
    sleep(0.5)
    display_table
  end

  def next_card
    card = dealer.deal(shoe)
    if card.cut_card?
      card = next_card
      @cut_card_message = CUT_CARD_MESSAGE
    end
    card
  end

  def show_results
    display_table
    players.each { |player| show_result(player) }
  end

  def show_result(player)
    player.message =
      if player.twenty_one?
        'Twenty-One!'
      elsif player.busted?
        'Busted!'
      elsif dealer.busted? || player_won?(player)
        'Winner!'
      elsif dealer_won?(player)
        "#{dealer.name} won."
      elsif draw?(player)
        'Draw.'
      end
    display_table
  end

  def winner(player)
    if player.busted?
      dealer
    elsif dealer.busted?
      player
    elsif player > dealer
      player
    elsif dealer > player
      dealer
    end
  end

  def player_won?(player)
    winner(player) == player
  end

  def dealer_won?(player)
    winner(player) == dealer
  end

  def draw?(player)
    player == dealer
  end

  def award_winners
    players.each do |player|
      if player.twenty_one?
        player.wallet.deposit(((TWENTY_ONE_PAYOUT) * player.bet) + player.bet)
      elsif player_won?(player)
        player.wallet.deposit(((STANDARD_PAYOUT) * player.bet) + player.bet)
      elsif draw?(player)
        player.wallet.deposit(player.bet)
      end
    end
  end

  def boot_broke_players
    broke_players = players.select { |player| player.wallet.empty? }
    broke_players.each do |player|
      players.delete(player)
      display_message "#{player.name}: You're out of cash. Goodbye."
    end
  end

  def close_table
    clear_table
    puts 'Table closed.'
  end

  def twenty_one?
    players.select(&:twenty_one?).each do |player|
      player.message = 'Twenty-One!'
      display_table
    end
  end

  def cash_out_players
    cashout_p = players.select { |player| cash_out?(player) }
    cashout_p.each do |player|
      players.delete(player)
      display_message "#{player.name}: Here's your #{player.wallet}. Goodbye."
    end
  end

  def cash_out?(player)
    puts "#{player.name}: Play another hand <enter> or cash out ($)?"
    gets.chomp.start_with?('$')
  end

  def wallet_empty?(player)
    player.wallet.empty?
  end

  def valid_bet?(player, bet)
    bet >= MIN_BET && player.wallet >= bet
  end

  def shoe_nearly_empty?
    @cut_card_message
  end
end

Game.new.start
