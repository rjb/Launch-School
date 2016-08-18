class Wallet
  CURRENCY = '$'

  attr_accessor :value

  def initialize(value = 10)
    @value = value
  end

  def deposit(amount)
    self.value += amount
  end

  def withdraw(amount)
    self.value -= amount unless amount > value
  end

  def to_s
    result = '%.2f' % value
    "#{CURRENCY}#{result}"
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

  def stay
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

  def twenty_one?
    hand.twenty_one? && hand.two_cards?
  end

  def busted?
    hand.busted?
  end
end

class Player < Participant
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
  # Put 4 decks of cards in the shoe
  # Place cut (red) card into shoe (near end)
  # Dealer deals and flips cards from the shoe
  # If dealer hits red card:
  #   1. finish the play
  #   2. shuffles 4 decks of cards
  DECK_COUNT = 4

  attr_reader :cards

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
    DECK_COUNT.times { @cards.push(*Deck.new.cards) }
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
  # UP and DOWN constants
  # Need RED_CARD

  attr_accessor :value
  attr_reader :state

  def initialize(value, state = 'down')
    @value = value
    @state = state
  end

  def to_s
    face_up? ? value.join('') : DOWN_CARD
  end

  def flip
    case state
    when 'up'
      @state = 'down'
    when 'down'
      @state = 'up'
    end
    self
  end

  def face_up?
    state == 'up'
  end

  def face_down?
    state == 'down'
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
end

class Game
  BID = 1
  STANDARD_PAYOUT = 1/1
  TWENTY_ONE_PAYOUT = 3.0/2.0
  GAME_MESSAGE = "Welcome to Twenty-One!\nMax bet: $1"

  attr_reader :shoe, :human, :dealer, :current_player

  def initialize
    @human = Player.new
    @dealer = Dealer.new
    @shoe = Shoe.new
  end

  def start
    # Need to check if out of cards and add in new deck if out
    shuffle_deck
    display_table

    loop do
      # Update to 'Deal (d), change bet (c), or cash out ($)'
      puts 'Deal (d) or cash out ($)'
      break if gets.chomp.start_with?('$')

      if wallet_empty?
        puts 'You are out of cash.'
        break
      end

      clear_table
      withraw_bid

      1.times do
        deal_initial_cards
        break if human.twenty_one?

        player_turn
        break if human.busted?

        dealer_turn
        puts 'Dealer busted!' if dealer.busted?
      end

      award_winner
      show_result
    end

    puts 'Goodbye!'
  end

  private

  def display_shuffling_deck
    cards = []
    2.times do
      15.times { display_cards_spreading(cards) }
      15.times { display_cards_shuffling(cards) }
    end
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

  def display_table
    system 'clear'
    display_game_message
    if block_given?
      puts '-----------------------------'
      yield
    end
    puts '-----------------------------'
    show_hands
    puts '-----------------------------'
  end

  def display_game_message
    puts GAME_MESSAGE
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

  # SIMPLIFY!!!
  def deal_card
    sleep(0.5)
    case current_player
    when human.name
      human.hit(dealer.deal(shoe))
    when dealer.name
      flip = dealer.hand.cards.count == 0 ? false : true
      dealer.hit(dealer.deal(shoe, flip))
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
      human.wallet.deposit(((TWENTY_ONE_PAYOUT) * BID) + BID)
    elsif human_won?
      human.wallet.deposit(((STANDARD_PAYOUT) * BID) + BID) if human_won?
    elsif draw?
      human.wallet.deposit(BID) if draw?
    end
  end

  def withraw_bid
    human.wallet.withdraw(BID)
  end

  def wallet_empty?
    human.wallet.empty?
  end
end

game = Game.new.start
