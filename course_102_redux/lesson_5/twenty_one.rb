class Participant
  attr_accessor :hand

  def initialize
    clear_hand
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
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
    self.total == other_player.total
  end

  def twenty_one?
    hand.twenty_one?
  end

  def busted?
    hand.busted?
  end
end

class Player < Participant
end

class Dealer < Participant
  HIT_MINIMUM = 17

  def deal(deck, flip = true)
    card = deck.deal
    card.flip if flip
    card
  end

  def reveal_hand
    hand.reveal
  end
end

class Deck
  SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"]
  RANKS = ('2'..'10').to_a + %w(J Q K A)

  attr_accessor :cards

  def initialize
    @cards = []
    initialize_cards
    # obviously, we need some data structure to keep track of cards
    # array, hash, something else?
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

  def to_s
    cards.map(&:to_s).join(' | ')
  end

  def twenty_one?
    self.total == 21
  end

  def busted?
    self.total > 21
  end
end

class Game
  GAME_MESSAGE = "Welcome to Twenty-One!\n$1 per game. First to $5 wins."
  FIRST_PLAYER = 'player'

  attr_reader :deck, :human, :dealer, :current_player

  def initialize
    @human = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def start
    shuffle_deck
    display_table

    loop do
      clear_table

      1.times do
        deal_initial_cards
        if human.twenty_one?
          puts '21!'
          break
        end

        player_turn
        if human.busted?
          puts 'Busted!'
          break
        end

        dealer_turn
        puts 'Dealer busted!' if dealer.busted?
      end

      show_result

      puts 'Clear table <enter> or Exit (x)'
      break if gets.chomp.start_with?('x')
    end

    puts 'Goodbye!'
  end

  private

  def display_shuffling_deck
    system 'clear'
    display_game_message
    puts '-----------------------------'
    puts 'shuffling...'
    puts '-----------------------------'
    sleep(0.5)
  end

  def display_table
    system 'clear'
    display_game_message
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
    puts "Player (#{human.total}): #{human.hand}"
    puts "Dealer (#{dealer.total}): #{dealer.hand}"
  end

  def shuffle_deck
    deck.shuffle
    display_shuffling_deck
  end

  def clear_table
    human.clear_hand
    dealer.clear_hand
    @current_player = FIRST_PLAYER
  end

  def player_turn
    loop do
      puts 'Hit (h) or Stand (s)?'
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

  # Change checks to players name (once implemented)
  def deal_card
    sleep(0.5)
    case current_player
    when 'player'
      human.hit(dealer.deal(deck))
    when 'dealer'
      flip = dealer.hand.cards.count == 0 ? false : true
      dealer.hit(dealer.deal(deck, flip))
    end
    display_table
  end

  # Change checks to players name (once implemented)
  def alternate_player
    case current_player
    when 'player'
      @current_player = 'dealer'
    when 'dealer'
      @current_player = 'player'
    end
  end

  def show_result
    puts determine_winner #.name
  end

  def determine_winner
    if human.busted?
      dealer
    elsif dealer.busted?
      human
    elsif human > dealer
      human
    elsif dealer > human
      dealer
    elsif human == dealer
      nil
    end
  end
end

game = Game.new.start
