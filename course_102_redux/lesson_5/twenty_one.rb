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

  attr_accessor :value

  def initialize(value = 100)
    @value = value
  end

  def deposit(amount)
    self.value += amount
  end

  def withdraw(amount)
    self.value -= amount unless amount > value
  end

  def <(amount)
    self.value < amount
  end

  def >=(amount)
    self.value >= amount
  end

  def to_s
    "#{format_as_currency(value)}"
  end

  def empty?
    self.value == 0
  end
end

class Participant
  attr_accessor :hand, :name

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

  def >(other_player)
    self.total > other_player.total
  end

  def ==(other_player)
    total == other_player.total
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

  def bet_made?
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
  CUT_CARD = "\u{1F0DF}"

  attr_reader :cards

  def initialize
    @cards = []
    initialize_cards
  end

  def shuffle
    cards.shuffle!
  end

  def place_cut_card
    @cards.insert(random_spot, Card.new(CUT_CARD))
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
    @cards << card
  end

  def total
    total = 0
    values = cards.select(&:face_up?).map { |card| card.value[0] }

    values.each do |value|
      if value == 'A'
        total += 11
      elsif %w(J K Q).include?(value)
        total += 10
      else
        total += value.to_i
      end
    end

    values.count('A').times do
      total -= 10 if total > 21
    end

    total
  end

  def reveal
    self.cards.each { |card| card.flip if card.face_down? }
  end

  def count
    cards.count
  end

  def to_s
    cards.map(&:to_s).join(' ')
  end

  def twenty_one?
    self.total == 21
  end

  def busted?
    self.total > 21
  end

  def two_cards?
    count == 2
  end

  def empty?
    count == 0
  end
end

class Game
  include Currency

  MIN_BET = 1
  STANDARD_PAYOUT = 1/1
  TWENTY_ONE_PAYOUT = 3.0/2.0
  CUT_CARD_MESSAGE = 'Cut card. Last hand before shuffle.'

  attr_reader :shoe, :human, :dealer, :current_player

  def initialize
    @human = Player.new
    @dealer = Dealer.new
  end

  def start
    reset_shoe

    loop do
      set_action
      clear_table
      withraw_bid

      1.times do
        deal_initial_cards
        break if human.twenty_one?

        player_turn
        break if human.busted?

        dealer_turn
      end

      award_winner
      show_result

      break if wallet_empty? || cash_out?

      clear_table_and_reset_shoe if shoe_nearly_empty?
    end

    cash_out
  end

  private

  def reset_shoe
    @shoe = Shoe.new
    @cut_card_message = nil
    shuffle_deck
    shoe.place_cut_card
    display_table
  end

  def clear_table_and_reset_shoe
    clear_table
    reset_shoe
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
    show_hands
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

  def set_bet
    bet = nil
    loop do
      puts 'Place your bet?'
      print Wallet::CURRENCY
      bet = gets.chomp.to_f
      break if valid_bet?(bet)
      display_invalid_bet_message(bet)
    end
    human.bet = bet
  end

  def set_action
    loop do
      set_bet
      puts 'Change bet (c) or deal (d)'
      break if gets.chomp.downcase.start_with?('d')
    end
  end

  def display_invalid_bet_message(bet)
    puts 'Bet is too low.' if bet < MIN_BET
    puts "You're wallet is a little light." if human.wallet < bet
  end

  def display_game_message
    puts "Welcome to Twenty-One!\nTable minimum: #{format_as_currency(MIN_BET)}"
  end

  def reveal_dealers_hand
    dealer.reveal_hand
    display_table
  end

  def show_hands
    show_dealers_hand
    puts
    show_humans_hand
  end

  def show_humans_hand
    puts "#{human.name} #{human.wallet}"
    puts "(#{human.total}): #{human.hand}"
  end

  def show_dealers_hand
    puts "#{dealer.name}"
    puts "(#{dealer.total}): #{dealer.hand}"
  end

  def shuffle_deck
    shoe.shuffle
    display_shuffling_deck
  end

  def clear_table
    human.clear_hand
    dealer.clear_hand
    @current_player = human.name
  end

  def player_turn
    loop do
      puts 'Hit (h) or stand (s)?'
      break unless gets.chomp.downcase == 'h'
      deal_card
      break if human.busted?
    end
    alternate_player
  end

  def dealer_turn
    reveal_dealers_hand
    while dealer.total < Dealer::HIT_MINIMUM
      deal_card
    end
  end

  def deal_initial_cards
    4.times do
      deal_card
      alternate_player
    end
  end

  def next_card
    card = dealer.deal(shoe)
    if card.cut_card?
      card = next_card
      @cut_card_message = CUT_CARD_MESSAGE
    end
    card
  end

  def deal_card
    sleep(0.5)
    card = next_card
    case current_player
    when human.name
      human.hit(card)
    when dealer.name
      card.flip if dealer.hand_empty?
      dealer.hit(card)
    end
    display_table
  end

  def alternate_player
    case current_player
    when human.name
      @current_player = dealer.name
    when dealer.name
      @current_player = human.name
    end
  end

  def show_result
    display_table
    display_busted_message
    display_twenty_one_message
    display_winner_message if someone_won?
    display_draw_message if draw?
  end

  def display_busted_message
    if human.busted?
      puts 'You busted.'
    elsif dealer.busted?
      puts 'Dealer busted.'
    end
  end

  def display_twenty_one_message
    puts '21!' if human.twenty_one?
  end

  def display_winner_message
    case winner
    when human
      puts "You win!"
    when dealer
      puts 'House wins.'
    end
  end

  def display_draw_message
    puts 'Draw.' if draw?
  end

  def winner
    if human.busted?
      dealer
    elsif dealer.busted?
      human
    elsif human > dealer
      human
    elsif dealer > human
      dealer
    end
  end

  def someone_won?
    !!winner
  end

  def human_won?
    winner == human
  end

  def draw?
    human == dealer
  end

  def award_winner
    if human.twenty_one?
      human.wallet.deposit(((TWENTY_ONE_PAYOUT) * human.bet) + human.bet)
    elsif human_won?
      human.wallet.deposit(((STANDARD_PAYOUT) * human.bet) + human.bet)
    elsif draw?
      human.wallet.deposit(human.bet) if draw?
    end
  end

  def withraw_bid
    human.wallet.withdraw(human.bet)
  end

  def cash_out
    display_cash_out_message
    display_goodbye_message
  end

  def cash_out?
    puts 'Play another hand <enter> or cash out ($)?'
    gets.chomp.start_with?('$')
  end

  def wallet_empty?
    human.wallet.empty?
  end

  def valid_bet?(bet)
    bet >= MIN_BET && human.wallet >= bet
  end

  def shoe_nearly_empty?
    @cut_card_message
  end
end

game = Game.new.start
