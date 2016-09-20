# Game engine
class Game
  include Display

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
    reset_bets
    reset_hands
    display_table
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

  def reset_bets
    players.each(&:reset_bet)
  end

  def reset_hands
    players.each(&:clear_hand)
    dealer.clear_hand
  end

  def table_empty?
    players.empty?
  end

  def display_message(msg)
    puts msg
    sleep(3)
    display_table
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
      display_place_bet_message(player)
      bet = gets.chomp.to_f
      break if valid_bet?(player, bet)
      display_invalid_bet_message(player, bet)
    end
    player.bet = bet
  end

  def withdraw_bet(player)
    player.wallet.withdraw(player.bet)
  end

  def reveal_dealers_hand
    dealer.reveal_hand
    display_table
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
      display_move_message(player)
      break unless gets.chomp.casecmp('h').zero?
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
    participant.message = busted_message
    display_table
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

  def show_results
    results
    reset_bets
    display_table
  end

  def results
    players.each { |player| result(player) }
  end

  def result(player)
    player.message =
      if player_won?(player)
        won_message(player)
      elsif dealer_won?(player)
        lost_message(player)
      else
        draw_message
      end
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
        pay(player, Rules::TWENTY_ONE_PAYOUT)
      elsif player_won?(player)
        pay(player, Rules::STANDARD_PAYOUT)
      elsif draw?(player)
        pay(player)
      end
    end
  end

  def pay(player, payout = 0)
    player.wallet.deposit((payout * player.bet) + player.bet)
  end

  def boot_broke_players
    broke_players.each do |player|
      players.delete(player)
      display_out_of_cash_message(player)
      display_table
    end
  end

  def broke_players
    players.select { |player| player.wallet.empty? }
  end

  def close_table
    reset_table
    display_table_closed_message
  end

  def check_for_twenty_one
    players.select(&:twenty_one?).each do |player|
      player.message = twenty_one_message
      display_table
    end
  end

  def cash_out_players
    players.delete_if { |player| cash_out?(player) }
  end

  def cash_out?(player)
    display_play_again_message(player)
    gets.chomp.start_with?('$')
  end

  def valid_bet?(player, bet)
    bet >= Rules::MIN_BET && player.wallet >= bet
  end
end
