VALID_CHOICES = { 'r' => 'rock', 'p' => 'paper', 's' => 'scissors', 'sp' => 'spock', 'l' => 'lizard' }

def prompt(message)
  puts "=> #{message}"
end

def win?(first, second)
  # rock crushes scissors and crushses lizard
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

loop do
  prompt("Welcome to Rock Paper Scissors Spock Lizard!")

  choice = ''
  loop do
    prompt("Choose your weapon wisely:")
    VALID_CHOICES.each { |k, v| prompt("#{v} (#{k})") }

    choice = gets.chomp
    break if VALID_CHOICES.keys.include?(choice)
  end

  computer_choice = VALID_CHOICES.keys.sample

  prompt("You chose: #{VALID_CHOICES[choice]}; Computer chose: #{VALID_CHOICES[computer_choice]}")

  if win?(choice, computer_choice)
    prompt("You won!")
  elsif win?(computer_choice, choice)
    prompt("Computer won.")
  else
    prompt("It's a draw!")
  end

  prompt("Play again? (y or n)")
  break unless gets.chomp.downcase.start_with?('y')
end

prompt("Thank you for playing. Good bye!")
