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

def display_table(hands, dealers_first_card = "down")
  players_hand = hands[:player].map(&:join)
  dealers_hand = hands[:dealer].map(&:join)

  if dealers_first_card == "down" && !dealers_hand.empty?
    dealers_hand[0] = "\u{1F0A0}"
  end

  sleep(1)
  system 'clear'
  puts "Welcome to Twenty-One!"
  puts "---"
  puts "Player: #{players_hand.join(' | ')}"
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

def display_winner(hands)
  player_total = total(hands[:player])
  dealer_total = total(hands[:dealer])

  if player_total == dealer_total
    puts "Push."
  elsif busted?(hands[:player])
    puts "House wins."
  elsif busted?(hands[:dealer])
    puts "You win!"
  elsif player_total < dealer_total
    puts "House wins."
  elsif dealer_total < player_total
    puts "You win!"
  end
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
  current_player = "player"
  dealers_first_card = "down"
  display_table(hands)

  1.times do
    # Deal
    4.times do
      deal_card(hands[current_player.to_sym], deck)
      display_table(hands)
      current_player = alternate(current_player)
    end

    if twenty_one?(hands[:player]) || twenty_one?(hands[:dealer])
      display_table(hands, flip(dealers_first_card))
      puts "Blackjack!"
      break
    end

    # Player
    loop do
      prompt "Hit (h) or Stand (s)?"
      break if gets.chomp.start_with?('s')

      deal_card(hands[:player], deck)
      display_table(hands)

      break if busted?(hands[:player])
    end

    if busted?(hands[:player])
      puts "You busted."
      break
    end

    display_table(hands, flip(dealers_first_card))

    # Dealer
    while total(hands[:dealer]) < 17
      prompt "Dealers turn..."

      deal_card(hands[:dealer], deck)
      display_table(hands, flip(dealers_first_card))
    end

    if busted?(hands[:dealer])
      puts "Dealer busted."
    end
  end

  display_winner(hands)
  prompt "Deal (d) or Exit (x)"
  break unless gets.chomp.start_with?('d')
end
