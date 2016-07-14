class Player
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Invalid name."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Choose rock, paper, or scissors:"
      choice = gets.chomp
      break if ['rock', 'paper', 'scissors'].include?(choice)
      puts "Invalid choice."
    end
    self.move = choice
  end
end

class Computer < Player
  def set_name
    self.name = %w(HAL C3PO Number5 GERTY RobotB-9 Rosie).sample
  end

  def choose
    self.move = ['rock', 'paper', 'scissors'].sample
  end
end

class Move
  def initialize
  end
end

class Rule
  def initialize
  end
end

def compare(move1, move2)
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to RPSGame!"
  end

  def display_goodbye_message
    puts "Thanks for playing. Goodbye!"
  end

  def display_winner
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
    case human.move
    when 'rock'
      puts "It's a tie" if computer.move == 'rock'
      puts "#{human.name} won" if computer.move == 'scissors'
      puts "#{computer.name} won" if computer.move == 'paper'
    when 'paper'
      puts "It's a tie" if computer.move == 'paper'
      puts "#{human.name} won" if computer.move == 'rock'
      puts "#{computer.name} won" if computer.move == 'scissors'
    when 'scissors'
      puts "It's a tie" if computer.move == 'scissors'
      puts "#{human.name} won" if computer.move == 'paper'
      puts "#{computer.name} won" if computer.move == 'rock'
    end
  end

  def play_again?
    response = nil

    loop do
      puts "Play again? (y/n)"
      response = gets.chomp
      break if ['y', 'n'].include?(response)
      puts "Invalid choice."
    end

    response == 'y' ? true : false
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
