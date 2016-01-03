VALID_CHOICES = %w(rock paper scissors)

def prompt(message)
  puts "=> #{message}"
end

def win?(first, second)
  (first == 'rock' && second == 'scissors') ||
    (first == 'paper' && second == 'rock') ||
    (first == 'scissors' && second == 'paper')
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
  elsif win?(choice, computer_choice)
    prompt("Computer won.")
  else
    prompt("It's a draw!")
  end

  prompt("Play again? (y or n)")
  break unless gets.chomp.downcase.start_with?('y')
end

prompt("Thank you for playing. Good bye!")
