# Game engine
class Game
  include Display
  include Computation

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
      deal_initial_cards
      check_for_twenty_one
      play_hand
      initialize_table
      break if table_empty?
    end
  end

  def initialize_table
    reset_shoe if shoe.low?
    reset_table
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
      display_player_count_request_message
      count = gets.chomp.to_i
      break if (1..Rules::SEATS).cover?(count)
      display_valid_player_count_message
    end
    count
  end

  def play_hand
    players_turns
    dealers_turn
    award_winners
    show_results
    boot_broke_players
    cash_out_players
  end

  def reset_shoe
    shoe.reset
    display_shuffling_deck
  end

  def close_table
    reset_table
    display_table_closed_message
  end

  def reset_table
    reset_messages
    reset_bets
    reset_hands
    display_table
  end
end
