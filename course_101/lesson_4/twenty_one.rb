SUITS = ["\u{2660}", "\u{2665}", "\u{2666}", "\u{2663}"]
RANKS = %w(1 2 3 4 5 6 7 8 9 J K Q A)

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
    if value == 'A'
      total += 11
    elsif %w(J K Q).include?(value)
      total += 10
    else
      total += value.to_i
    end
  end

  values.select { |value| value == 'A' }.count.times do
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

def display_winner(hands)
  player_total = total(hands[:player])
  dealer_total = total(hands[:dealer])

  if bust?(hands[:player]) && bust?(hands[:dealer])
    puts "Draw."
  elsif bust?(hands[:player])
    puts "House wins."
  elsif bust?(hands[:dealer])
    puts "You win!"
  elsif player_total == dealer_total
    puts "Draw."
  elsif player_total > dealer_total
    puts "You win!"
  elsif dealer_total > player_total
    puts "House wins!"
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

def alternate(player)
  player == "player" ? "dealer" : "player"
end

loop do
  deck = initialize_deck
  hands = intialize_hands
  dealer_card = "down"
  current_player = "player"
  display(hands)

  loop do
    # Deal
    4.times do
      deal_card(hands[current_player.to_sym], deck)
      display(hands)
      current_player = alternate(current_player)
    end

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
