class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    set_score
  end

  def set_score
    self.score = Score.new
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
      break if Move::VALUES.include?(choice)
      puts "Invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = %w(HAL C3PO Number5 GERTY RobotB-9 Rosie).sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def to_s
    @value
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end
end

class Score
  INITIAL_SCORE = 0

  def initialize
    @value = INITIAL_SCORE
  end

  def add_point
    @value += 1
  end

  def to_s
    "#{@value}"
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

  def award_winner
    if human.move > computer.move
      human.score.add_point
    elsif human.move < computer.move
      computer.score.add_point
    end
  end

  def display_winner
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"

    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie."
    end

    puts "Score:"
    puts "Human: #{human.score}"
    puts "Computer: #{computer.score}"
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
      award_winner
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
