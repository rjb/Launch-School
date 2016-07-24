module Personality
  def personality_choice(type)
    if type == 'erratic'
      erratic
    elsif type == 'partial'
      partial
    elsif type == 'intelligent'
      intelligent
    end
  end

  private

  def intelligent
    # If 60% of choice results in loss, then doesn't pick that choice
    Weapon::VALUES.select { |item| !losses_by_weight.include?(item) }.sample
  end

  def erratic
    # Random choice
    Weapon::VALUES.sample
  end

  def partial
    # Favors rock 60% of the time
    arr = []
    Weapon::ROCK_HEAVY.each do |item, weight|
      weight.times { arr << item }
    end
    arr.sample
  end

  def losses_by_weight(weight = 0.6)
    losses_weight.select { |_, v| v >= weight }.keys
  end

  def losses_weight
    result = {}
    Weapon::VALUES.each do |value|
      weight = moves.count { |move| move == [value, "lose"] } / moves.count.to_f
      result[value] = weight.nan? ? 0 : weight
    end
    result
  end
end

class Player
  attr_accessor :move, :moves, :name, :score

  def initialize
    set_name
    @moves = []
  end

  def initialize_score
    self.score = Score.new
  end

  def log_move(result)
    moves << ["#{move}", result]
  end

  def give_point
    score.add_point
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
      puts "Choose #{Weapon.choices}:"
      choice = gets.chomp
      break if Weapon::VALUES.include?(choice)
      puts "Invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  include Personality

  COMPUTERS = {
    'HAL' => 'intelligent',
    'C-3PO' => 'erratic',
    'Number5' => 'partial',
    'GERTY' => 'intelligent',
    'RobotB-9' => 'erratic',
    'Rosie' => 'partial'
  }

  def set_name
    self.name = COMPUTERS.keys.sample
  end

  def choose
    self.move = Move.new(personality_choice(COMPUTERS[name]))
  end
end

class Weapon
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

  ROCK_HEAVY = {
    "rock" => 6,
    "paper" => 1,
    "scissors" => 1,
    "spock" => 1,
    "lizard" => 1
  }

  def self.choices
    weapons = VALUES.map do |item|
      item == VALUES.last ? "or #{item}" : item
    end
    weapons.join(', ')
  end
end

class Rock
  def beats?(other_move)
    other_move.value.class == Scissors ||
      other_move.value.class == Lizard
  end
end

class Paper
  def beats?(other_move)
    other_move.value.class == Rock ||
      other_move.value.class == Spock
  end
end

class Scissors
  def beats?(other_move)
    other_move.value.class == Paper ||
      other_move.value.class == Lizard
  end
end

class Spock
  def beats?(other_move)
    other_move.value.class == Rock ||
      other_move.value.class == Scissors
  end
end

class Lizard
  def beats?(other_move)
    other_move.value.class == Paper ||
      other_move.value.class == Spock
  end
end

class Move
  attr_reader :value

  def initialize(value)
    @value = Move.initialize_weapon(value)
  end

  def >(other_move)
    @value.beats?(other_move)
  end

  def <(other_move)
    !value.beats?(other_move)
  end

  def to_s
    "#{@value.class}"
  end

  def self.initialize_weapon(value)
    if value == 'rock'
      Rock.new
    elsif value == 'paper'
      Paper.new
    elsif value == 'scissors'
      Scissors.new
    elsif value == 'spock'
      Spock.new
    elsif value == 'lizard'
      Lizard.new
    end
  end
end

class Score
  INITIAL_SCORE = 0
  WINNING_SCORE = 10

  def initialize
    @value = INITIAL_SCORE
  end

  def add_point
    @value += 1
  end

  def ==(value)
    @value == value
  end

  def to_s
    "#{@value}"
  end
end

class RPSGame
  DIVIDER = "-" * 38

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_game_board
    display_welcome_message
    display_moves
    display_winner
    display_score
  end

  def display_welcome_message
    system 'clear'
    puts DIVIDER
    puts "Welcome to RPSGame! First to 10 wins."
    puts DIVIDER
  end

  def display_goodbye_message
    puts "Thanks for playing. Goodbye!"
  end

  def display_score
    puts DIVIDER
    puts "#{human.name}: #{human.score} | " \
           "#{computer.name}: #{computer.score}"
    puts DIVIDER
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie."
    end
  end

  def display_game_winner
    if human.score == Score::WINNING_SCORE
      puts "#{human.name} won the game!"
    elsif computer.score == Score::WINNING_SCORE
      puts "#{computer.name} won the game!"
    end
  end

  def award_winner
    if human_won?
      human.give_point
    elsif computer_won?
      computer.give_point
    end
  end

  def human_result
    if human_won?
      "win"
    elsif computer_won?
      "lose"
    else
      "tie"
    end
  end

  def computer_result
    if computer_won?
      "win"
    elsif human_won?
      "lose"
    else
      "tie"
    end
  end

  def human_won?
    human.move > computer.move
  end

  def computer_won?
    computer.move > human.move
  end

  def game_over?
    human.score == Score::WINNING_SCORE ||
      computer.score == Score::WINNING_SCORE
  end

  def play_again?
    response = nil
    loop do
      puts "Play another game? (y/n)"
      response = gets.chomp
      break if ['y', 'n'].include?(response)
      puts "Invalid choice."
    end
    response == 'y'
  end

  def initialize_score
    human.initialize_score && computer.initialize_score
  end

  def new_hand
    loop do
      human.choose
      computer.choose
      human.log_move(human_result)
      computer.log_move(computer_result)
      award_winner
      display_game_board
      break if game_over?
    end
  end

  def new_game
    loop do
      display_welcome_message
      initialize_score
      new_hand
      display_game_winner
      break unless play_again?
    end
    display_goodbye_message
  end

  def play
    new_game
  end
end

RPSGame.new.play
