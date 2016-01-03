VALID_CHOICES = { r: 'rock', p: 'paper', s: 'scissors', sp: 'spock', l: 'lizard' }
scores = { human: 0, computer: 0 }

def prompt(message)
  puts "=> #{message}"
end

def display_welcome_message
  puts "--------------------------------------------"
  puts "Welcome to Rock Paper Scissors Spock Lizard!"
  puts "--------------------------------------------"
  puts "Your battle against Computer begins now."
  puts "(best to 5 wins)"
  puts "--------------------------------------------"
end

def display_scoreboard(scores)
  puts "---------------"
  puts "Scoreboard"
  puts "---------------"
  scores.each { |player, score| puts "#{player}: #{score}" }
  puts "---------------"
end

def display_choices
  prompt("Choose your weapon wisely:")
  VALID_CHOICES.each { |k, v| prompt("#{v} (#{k})") }
end

def win?(first, second)
  # rock crushes scissors and crushes lizard
  %w(r).product(%w(s l)).include?([first, second]) ||
    # paper covers rock and disproves spock
    %w(p).product(%w(r sp)).include?([first, second]) ||
    # scissors cuts paper and decapitates lizard
    %w(s).product(%w(p l)).include?([first, second]) ||
    # spock vaporizes rock and smashes scissors
    %w(sp).product(%w(r s)).include?([first, second]) ||
    # lizard eats paper and poisons spock
    %w(l).product(%w(p sp)).include?([first, second])
end

def game_over?(scores)
  scores[:human] == 5 || scores[:computer] == 5
end

def display_final_results(scores)
  if scores[:human] == 5
    prompt("GAME OVER: You won!")
  elsif scores[:computer] == 5
    prompt("GAME OVER: Computer has defeated you...")
  end
end

loop do
  display_welcome_message

  loop do
    choice = ''
    loop do
      display_choices

      choice = gets.chomp
      break if VALID_CHOICES.keys.include?(choice.to_sym)
    end

    computer_choice = VALID_CHOICES.keys.sample.to_s

    prompt("You chose: #{VALID_CHOICES[choice.to_sym]}; Computer chose: #{VALID_CHOICES[computer_choice.to_sym]}")

    if win?(choice, computer_choice)
      prompt("You won the round!")
      scores[:human] += 1
    elsif win?(computer_choice, choice)
      prompt("Computer won the round")
      scores[:computer] += 1
    else
      prompt("Round is a draw")
    end

    display_scoreboard(scores)

    if game_over?(scores)
      display_final_results(scores)
      break
    end

    prompt("Press <enter> to play another round, or forfeit (f)")
    break if gets.chomp.downcase.start_with?('f')
  end

  prompt("Up for another game? (y or n)")
  break unless gets.chomp.downcase.start_with?('y')
end

prompt("Thank you for playing. Good bye!")
