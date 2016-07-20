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
    self.moves << ["#{move}", result]
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
    choices = Move::VALUES.select do |item|
      !losses.include?(item)
    end
    self.move = Move.new(choices.sample)
  end

  def losses
    losses_weight.select { |k,v| v >= 0.6 }.keys
  end

  def losses_weight
    result = {}
    Move::VALUES.each do |value|
      weight = moves.count { |move| move == [value, "lose"] } / moves.count.to_f
      result[value] = weight.nan? ? 0 : weight
    end
    result
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
    puts "#{human.moves}"
    puts "#{computer.moves}"
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
      human.score.add_point
    elsif computer_won?
      computer.score.add_point
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
    response == 'y' ? true : false
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
