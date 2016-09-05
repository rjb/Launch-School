# Money related actions
module Currency
  CURRENCIES = {
    'US' => '$',
    'UK' => '£',
    'EU' => '€',
    'JP' => '¥'
  }

  def format_as_currency(amount)
    format "#{Wallet::CURRENCY}%.2f", amount
  end
end

# Used to hold and keep track of player's money
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

  def <(other)
    value < other
  end

  def >=(other)
    value >= other
  end

  def to_s
    format_as_currency(value)
  end

  def empty?
    value == 0
  end
end

# Parent class for player and dealer objects
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
    hand << card
  end

  def total
    hand.total
  end

  def reset_message
    self.message = nil
  end

  def >(other)
    total > other.total
  end

  def ==(other)
    total == other.total
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
    !bet.nil?
  end
end

# Deals cards from shoe
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

# Holds decks of cards from which cards are dealt
class Shoe
  DECK_COUNT = 4
  LOW_CARD_COUNT_MESSAGE = 'Low on cards. Last hand before shuffle.'
  STATES = { full: 'full', low: 'low' }

  attr_reader :cards, :state

  def initialize
    @cards = []
  end

  def reset
    cards.clear
    load_cards
    shuffle_cards
    place_cut_card
    @state = STATES[:full]
  end

  def shuffle_cards
    cards.shuffle!
  end

  def place_cut_card
    @cards.insert(random_spot, Card.new(Card::CUT_CARD))
  end

  def deal
    card = cards.shift
    if card.cut_card?
      @state = STATES[:low]
      deal
    else
      card
    end
  end

  def full?
    state == STATES[:full]
  end

  def low?
    # Maybe track the spot where the cut card was placed,
    # rather that tracking state
    state == STATES[:low] || cards.empty?
  end

  private

  def load_cards
    DECK_COUNT.times { @cards.push(*Deck.new.cards) }
  end

  def random_spot
    -(size * rand(0.15..0.25))
  end

  def size
    cards.length
  end
end

# Standard deck of playing cards
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

# Class for creating cards with any value
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

  def rank
    value.first
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
    count == 0
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

# Defines table settings
# Maybe bring all table related objects and actions here?
class Table
  SEATS = 5
end

# Logic and rules
class Game
  include Currency

  MIN_BET = 1
  STANDARD_PAYOUT = 1 / 1
  TWENTY_ONE_PAYOUT = 3.0 / 2.0

  attr_reader :players, :dealer, :shoe

  def initialize
    @players = []
    @dealer = Dealer.new
    @shoe = Shoe.new
    initialize_players
    initialize_table
  end

  def start
    play
    close_table
  end

  private

  def play
    loop do
      place_bets
      play_initial_cards
      play_hand
      initialize_table
      break if table_empty?
    end
  end

  def initialize_players
    player_count.times do |i|
      print "Player #{i + 1}: "
      @players << Player.new
    end
  end

  def player_count
    count = nil
    loop do
      puts "How many players? (1-#{Table::SEATS})"
      count = gets.chomp.to_i
      break if (1..Table::SEATS).include?(count)
      puts "Enter a valid number, between 1 and #{Table::SEATS}."
    end
    count
  end

  def initialize_table
    reset_shoe if shoe.low?
    reset_table
  end

  def reset_shoe
    shoe.reset
    display_shuffling_deck
  end

  def reset_table
    reset_messages
    players.each(&:reset_bet)
    players.each(&:clear_hand)
    dealer.clear_hand
    display_table
  end

  def play_initial_cards
    deal_initial_cards
    check_for_twenty_one
  end

  def play_hand
    players_turns
    dealers_turn
    award_winners
    show_results
    boot_broke_players
    cash_out_players
  end

  def reset_messages
    players.each(&:reset_message)
    dealer.reset_message
  end

  def table_empty?
    players.empty?
  end

  def display_message(msg)
    puts msg
    sleep(3)
    display_table
  end

  def display_shuffling_deck
    cards = []
    15.times { display_cards_growing(cards) }
    15.times { display_cards_shrinking(cards) }
    15.times { display_cards_growing(cards) }
  end

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

  def display_table
    system 'clear'
    puts game_message
    puts '-----------------------------'
    block_given? ? yield : display_shoe
    puts '-----------------------------'
    show_dealers_hand
    show_players_hands
    puts '-----------------------------'
  end

  def game_message
    "Welcome to Twenty-One!\nTable minimum: #{format_as_currency(MIN_BET)}"
  end

  def display_low_card_count_message
    puts Shoe::LOW_CARD_COUNT_MESSAGE
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

  def display_invalid_bet_message(player, bet)
    puts 'Bet is too low.' if bet < MIN_BET
    puts "You're wallet is a little light." if player.wallet < bet
  end

  def reveal_dealers_hand
    dealer.reveal_hand
    display_table
  end

  def show_dealers_hand
    puts "#{dealer.name}"
    puts "#{show_total(dealer)} #{dealer.hand} #{show_message(dealer)}"
    puts
  end

  def show_players_hands
    players.each do |player|
      puts "#{player.name} #{show_wallet(player)} #{show_bet(player)}"
      puts "#{show_total(player)} #{player.hand} #{show_message(player)}"
      puts
    end
  end

  def show_total(participant)
    "(#{participant.total})" unless participant.hand_empty?
  end

  def show_message(participant)
    "- #{participant.message}" if participant.message
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

  def active_players
    players.select { |p| !p.twenty_one? }
  end

  def players_turns
    active_players.each do |player|
      player_turn(player)
      bust(player) if player.busted?
    end
  end

  def player_turn(player)
    loop do
      puts "#{player.name}: Hit (h) or stand (s)?"
      break unless gets.chomp.downcase == 'h'
      deal_card(player)
      break if player.busted?
    end
  end

  def dealers_turn
    reveal_dealers_hand
    return if players.all?(&:twenty_one?) || players.all?(&:busted?)
    deal_card(dealer) while dealer.total < Dealer::HIT_MINIMUM
    bust(dealer) if dealer.busted?
  end

  def bust(participant)
    participant.message = 'Busted!'
    display_table
  end

  def deal_initial_cards
    2.times do
      players.each { |player| deal_card(player) }
      deal_card(dealer, dealer.hand_empty?)
    end
  end

  def deal_card(player, flip = false)
    card = dealer.deal(shoe)
    card.flip if flip
    player.hit(card)
    sleep(0.5)
    display_table
  end

  def show_results
    players.each { |player| show_result(player) }
    display_table
  end

  def show_result(player)
    player.message =
      if player_won?(player)
        won_message(player)
      elsif dealer_won?(player)
        lost_message(player)
      else
        draw_message
      end
  end

  def won_message(player)
    player.twenty_one? ? 'Twenty-One!' : 'Winner!'
  end

  def lost_message(player)
    player.busted? ? 'Busted!' : "#{dealer.name} won"
  end

  def draw_message
    'Draw.'
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
        pay(player, TWENTY_ONE_PAYOUT)
      elsif player_won?(player)
        pay(player, STANDARD_PAYOUT)
      elsif draw?(player)
        pay(player)
      end
    end
  end

  def pay(player, payout = 0)
    player.wallet.deposit(((payout) * player.bet) + player.bet)
  end

  def boot_broke_players
    broke_players.each do |player|
      players.delete(player)
      display_message "#{player.name}: You're out of cash. Goodbye."
    end
  end

  def broke_players
    players.select { |player| player.wallet.empty? }
  end

  def close_table
    reset_table
    puts 'Table closed.'
  end

  def check_for_twenty_one
    players.select(&:twenty_one?).each do |player|
      player.message = 'Twenty-One!'
      display_table
    end
  end

  def cash_out_players
    players.delete_if { |player| cash_out?(player) }
  end

  def cash_out?(player)
    puts "#{player.name}: Play another hand <enter> or cash out ($)?"
    gets.chomp.start_with?('$')
  end

  def valid_bet?(player, bet)
    bet >= MIN_BET && player.wallet >= bet
  end
end

Game.new.start
