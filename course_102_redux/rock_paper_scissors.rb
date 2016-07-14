class Player
  attr_accessor :move, :name

  def initialize(player_type = :human)
    @player_type = player_type
    @move = nil
    set_name
  end

  def set_name
    if human?
      name = ""
      loop do
        puts "What is your name?"
        name = gets.chomp
        break unless name.empty?
        puts "Invalid name."
      end
      self.name = name
    else
      self.name = %w(HAL C3PO Number5 GERTY RobotB-9 Rosie).sample
    end
  end

  def choose
    if human?
      choice = nil
      loop do
        puts "Choose rock, paper, or scissors:"
        choice = gets.chomp
        break if ['rock', 'paper', 'scissors'].include?(choice)
        puts "Invalid choice."
      end
      self.move = choice
    else
      self.move = ['rock', 'paper', 'scissors'].sample
    end
  end

  def human?
    @player_type == :human
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
    @human = Player.new
    @computer = Player.new(:computer)
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
      @human.choose
      @computer.choose
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
