GAME_MESSAGE = "Welcome to Twenty-One!"
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

def display_shuffling_deck
  12.times do
    deck1 = initialize_deck[0..4]
    deck2 = initialize_deck[0..4]
    system 'clear'
    puts "#{GAME_MESSAGE}"
    puts "----------------------"
    puts "#{deck1.map(&:join).join(' | ')}"
    puts "#{deck2.map(&:join).join(' | ')}"
    puts "----------------------"
    sleep(0.2)
  end
end

def display_players_hand(players_hand)
  puts "Player: #{players_hand.map(&:join).join(' | ')}"
end

def display_dealers_hand(dealers_hand, show_dealers_first_card = false)
  dealers_hand = dealers_hand.map(&:join)

  if !show_dealers_first_card && !dealers_hand.empty?
    dealers_hand[0] = "\u{1F0A0}"
  end

  puts "Dealer: #{dealers_hand.join(' | ')}"
end

def display_table(hands, show_dealers_first_card = false)
  system 'clear'
  puts "#{GAME_MESSAGE}"
  puts "----------------------"
  display_players_hand(hands[:player])
  display_dealers_hand(hands[:dealer], show_dealers_first_card)
  puts "----------------------"
  sleep(0.5)
end

def display_results(hands)
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

display_shuffling_deck

loop do
  deck = initialize_deck
  hands = intialize_hands
  current_player = "player"

  display_table(hands)

  prompt "Deal (d) or Exit (x)"
  break unless gets.chomp.start_with?('d')

  1.times do
    # Deal
    4.times do
      deal_card(hands[current_player.to_sym], deck)
      display_table(hands)
      current_player = alternate(current_player)
    end

    if twenty_one?(hands[:player]) || twenty_one?(hands[:dealer])
      display_table(hands, true)
      puts "Twenty-One!"
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
      display_table(hands, true)
      puts "You busted."
      break
    end

    display_table(hands, true)

    # Dealer
    while total(hands[:dealer]) < 17
      prompt "Dealer's turn..."
      deal_card(hands[:dealer], deck)
      display_table(hands, true)
    end

    if busted?(hands[:dealer])
      puts "Dealer busted."
    end
  end

  display_results(hands)
  prompt "Clear table <enter> or Exit (x)"
  break if gets.chomp.start_with?('x')
end
