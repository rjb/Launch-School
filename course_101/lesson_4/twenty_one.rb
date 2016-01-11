require 'pry'
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

def display(hands, hide_dealers_first = "down")
  dealers_hand = hands[:dealer].map(&:join)
  if hide_dealers_first == "down" && hands[:dealer].count <= 2 && hands[:dealer].count >= 1
    dealers_hand[0] = "\u{1F0A0}" 
  end

  sleep(1)
  system 'clear'
  puts "Welcome to Twenty-One!"
  puts "---"
  puts "Player: #{hands[:player].map(&:join).join(' | ')}"
  puts "Dealer: #{dealers_hand.join(' | ')}"
  puts "---"
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
    puts "#{winner} wins."
  end
end

def game_over?(hands)
  bust?(hands[:player]) || bust?(hands[:dealer])
end

def flip(card)
  if card == "down"
    "up"
  else
    "down"
  end
end

loop do
  deck = initialize_deck
  hands = intialize_hands
  dealer_card = "down"
  display(hands)

  loop do
    deal_card(hands[:player], deck)
    display(hands)
    deal_card(hands[:dealer], deck)
    display(hands)    
    deal_card(hands[:player], deck)
    display(hands)
    deal_card(hands[:dealer], deck)
    display(hands)

    # Player
    loop do
      prompt "Hit (h) or Stand (s)?"
      break unless gets.chomp.start_with?('h')
      
      deal_card(hands[:player], deck)
      display(hands)

      if bust?(hands[:player])
        puts "Bust."
        break
      end
    end

    break if game_over?(hands)

    dealer_card = flip(dealer_card)
    display(hands, dealer_card)

    # Dealer
    while total(hands[:dealer]) < 17
      prompt "Dealers turn..."
      
      deal_card(hands[:dealer], deck)
      display(hands, dealer_card)

      if bust?(hands[:dealer])
        puts "Bust."
        break
      end
    end

    break
  end

  display(hands, dealer_card)
  display_winner(hands)

  prompt "Play again? (y or n)"
  break unless gets.chomp.start_with?('y')
end
