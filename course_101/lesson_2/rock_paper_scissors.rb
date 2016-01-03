VALID_CHOICES = %w(rock paper scissors spock lizard)

def prompt(message)
  puts "=> #{message}"
end

def win?(first, second)
  (first == 'rock' && second == 'scissors') ||
    (first == 'rock' && second == 'lizard') ||
    (first == 'paper' && second == 'rock') ||
    (first == 'paper' && second == 'spock') ||
    (first == 'scissors' && second == 'paper') ||
    (first == 'scissors' && second == 'lizard') ||
    (first == 'spock' && second == 'rock') ||
    (first == 'spock' && second == 'scissors') ||
    (first == 'lizard' && second == 'paper') ||
    (first == 'lizard' && second == 'spock')
end

loop do
  choice = ''

  loop do
    prompt("Choose one: #{VALID_CHOICES.join(', ')}")
    choice = gets.chomp
    break if VALID_CHOICES.include?(choice)
  end

  computer_choice = VALID_CHOICES.sample

  prompt("You chose: #{choice}; Computer chose: #{computer_choice}")

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
