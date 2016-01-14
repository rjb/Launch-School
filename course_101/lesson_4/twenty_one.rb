GAME_MESSAGE = "Welcome to Twenty-One!\n$1 per win. First to $5 wins."
WINNING_SCORE = 5
SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"]
RANKS = ('2'..'10').to_a + %w(J Q K A)

def prompt(message)
  puts "=> #{message}"
end

def initialize_deck
  RANKS.product(SUITS).shuffle
end

def intialize_hands
  { player: [], dealer: [] }
end

def initialize_wallets
  { player: 0, dealer: 0 }
end

def display_shuffling_deck
  12.times do
    system 'clear'
    puts "#{GAME_MESSAGE}"
    puts "-----------------------------"
    puts "#{initialize_deck[0..5].map(&:join).join(' | ')}"
    puts "#{initialize_deck[0..5].map(&:join).join(' | ')}"
    puts "-----------------------------"
    sleep(0.2)
  end
end

def display_players_hand(players_hand, players_wallet)
  puts "Player $#{players_wallet} (#{total(players_hand)}): #{players_hand.map(&:join).join(' | ')}"
end

def display_dealers_hand(dealers_hand, dealers_wallet, show_dealers_first_card = false)
  dealers_hand = Array.new(dealers_hand)
  total = total(dealers_hand)

  if !show_dealers_first_card && !dealers_hand.empty?
    total -= total([dealers_hand.first])
    dealers_hand[0] = ["\u{1F0A0}"]
  end

  puts "Dealer $#{dealers_wallet} (#{total}): #{dealers_hand.map(&:join).join(' | ')}"
end

def display_table(hands, wallets, show_dealers_first_card = false)
  system 'clear'
  puts "#{GAME_MESSAGE}"
  puts "-----------------------------"
  display_players_hand(hands[:player], wallets[:player])
  display_dealers_hand(hands[:dealer], wallets[:dealer], show_dealers_first_card)
  puts "-----------------------------"
  sleep(0.5)
end

def display_results(hands)
  case determine_winner(hands)
  when "player"
    puts "You win!"
  when "dealer"
    puts "House wins."
  else
    puts "Push."
  end
end

def deal_card(player, deck)
  player << deck.shift
end

def total(hand)
  total = 0
  values = hand.map { |value| value[0] }

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

def twenty_one?(hand)
  total(hand) == 21
end

def busted?(hand)
  total(hand) > 21
end

def alternate(player)
  player == "player" ? "dealer" : "player"
end

def someone_won?(hands)
  !!determine_winner(hands)
end

def determine_winner(hands)
  player_total = total(hands[:player])
  dealer_total = total(hands[:dealer])
  if player_total == dealer_total
    nil
  elsif busted?(hands[:player])
    "dealer"
  elsif busted?(hands[:dealer])
    "player"
  elsif player_total < dealer_total
    "dealer"
  elsif dealer_total < player_total
    "player"
  end
end

def award_winner(winner, wallets)
  wallets[winner.to_sym] += 1
end

def detect_game_winner(wallets)
  if wallets[:player] == WINNING_SCORE
    "Player"
  elsif wallets[:dealer] == WINNING_SCORE
    "Dealer"
  end
end

def game_over?(wallets)
  wallets[:player] == WINNING_SCORE || wallets[:dealer] == WINNING_SCORE
end

loop do
  display_shuffling_deck
  wallets = initialize_wallets

  loop do
    deck = initialize_deck
    hands = intialize_hands
    current_player = "player"

    display_table(hands, wallets)

    prompt "Deal (d) or Exit (x)"
    break unless gets.chomp.start_with?('d')

    1.times do
      # Deal
      4.times do
        deal_card(hands[current_player.to_sym], deck)
        display_table(hands, wallets)
        current_player = alternate(current_player)
      end

      if twenty_one?(hands[:player])
        display_table(hands, wallets, true)
        puts "Twenty-One!"
        break
      end

      # Player
      loop do
        prompt "Hit (h) or Stand (s)?"
        break if gets.chomp.start_with?('s')

        deal_card(hands[:player], deck)
        display_table(hands, wallets)

        break if busted?(hands[:player])
      end

      if busted?(hands[:player])
        display_table(hands, wallets, true)
        puts "You busted."
        break
      end

      display_table(hands, wallets, true)

      # Dealer
      while total(hands[:dealer]) < 17
        deal_card(hands[:dealer], deck)
        display_table(hands, wallets, true)
      end

      if busted?(hands[:dealer])
        puts "Dealer busted."
      end
    end

    if someone_won?(hands)
      award_winner(determine_winner(hands), wallets)
    end

    display_results(hands)

    if game_over?(wallets)
      prompt("Game over! #{detect_game_winner(wallets)} won the game!")
      break
    end

    prompt "Clear table <enter> or Exit (x)"
    break if gets.chomp.start_with?('x')
  end

  prompt "Play another game? (y or n)"
  break unless gets.chomp.start_with?('y')
end
