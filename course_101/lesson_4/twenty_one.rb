SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"]
RANKS = %w(1 2 3 4 5 6 7 8 9 Jack King Queen Ace)

def prompt(message)
  puts "=> #{message}"
end

def initialize_deck
  RANKS.product(SUITS).shuffle
end

def intialize_hands
  { player: [], dealer: [] }
end

def display_hands(hands)
  system 'clear'
  puts "Welcome to Twenty-One!"
  puts "---"
  puts "Player (#{total(hands[:player])}): #{hands[:player].map(&:join).join(' | ')}"
  puts "Dealer (#{total(hands[:dealer])}): #{hands[:dealer].map(&:join).join(' | ')}"
  puts "---"
  sleep(1)
end

def deal_card(player, deck)
  player << deck.shift
end

def total(hand)
  total = 0
  values = hand.map { |value| value[0] }

  values.each do |value|
    if value == 'Ace'
      total += 11
    elsif %w(Jack King Queen).include?(value)
      total += 10
    else
      total += value.to_i
    end
  end

  values.select { |value| value == 'Ace' }.count.times do
    total -= 10 if total > 21
  end

  total
end

def twenty_one?(hand)
  total(hand) == 21
end

def bust?(hand)
  total(hand) > 21
end

def determine_winner(hands)
  player_total = total(hands[:player])
  dealer_total = total(hands[:dealer])

  if bust?(hands[:player]) && bust?(hands[:dealer])
    "Draw"
  elsif bust?(hands[:player])
    "Dealer"
  elsif bust?(hands[:dealer])
    "Player"
  elsif player_total == dealer_total
    "Draw"
  elsif player_total > dealer_total
    "Player"
  elsif dealer_total > player_total
    "Dealer"
  end
end

def display_winner(hands)
  winner = determine_winner(hands)
  if winner == "Draw"
    puts "Game is a draw."
  else
    puts "#{winner} wins!"
  end
end

def game_over?(hands)
  bust?(hands[:player]) || bust?(hands[:dealer])
end

loop do
  deck = initialize_deck
  hands = intialize_hands
  display_hands(hands)

  loop do
    deal_card(hands[:player], deck)
    display_hands(hands)
    deal_card(hands[:dealer], deck)
    display_hands(hands)    
    deal_card(hands[:player], deck)
    display_hands(hands)
    deal_card(hands[:dealer], deck)
    display_hands(hands)

    # Player
    loop do
      prompt "Hit (h) or Stand (s)?"
      break unless gets.chomp.start_with?('h')
      
      deal_card(hands[:player], deck)
      display_hands(hands)

      if bust?(hands[:player])
        prompt "Bust."
        break
      end
    end

    break if game_over?(hands)

    # Dealer
    while total(hands[:dealer]) < 17
      prompt "Dealers turn..."
      
      deal_card(hands[:dealer], deck)
      display_hands(hands)

      if bust?(hands[:dealer])
        prompt "Bust."
        break
      end
    end

    break
  end

  display_winner(hands)

  prompt "Play again? (y or n)"
  break unless gets.chomp.start_with?('y')
end
