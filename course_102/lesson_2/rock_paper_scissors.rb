class Player
  attr_accessor :name, :move, :score

  def initialize
    set_name
  end

  def set_score
    self.score = Score.new
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      choices = Move::VALUES.map { |accr, value| "#{value} (#{accr})" }.join(', ')
      puts "Choose #{choices}"
      choice = gets.chomp.to_sym
      break if Move::VALUES.keys.include?(choice)
      puts "Invalid choice!"
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = %w(HAL C3PO Number5 GERTY RobotB-9 Rosie).sample
  end

  def choose
    self.move = Move.new(Move::VALUES.keys.sample)
  end
end

class Move
  VALUES = { r: "rock", p: "paper", s: "scissors", l: "lizard", sp: "spock" }

  def initialize(value)
    @value = value
  end

  def rock?
    @value == :r
  end

  def paper?
    @value == :p
  end

  def scissors?
    @value == :s
  end

  def lizard?
    @value == :l
  end

  def spock?
    @value == :sp
  end

  def to_s
    VALUES[@value]
  end

  def >(other)
    [rock?].product([other.scissors?, other.lizard?]).include?([true, true]) ||
      [paper?].product([other.rock?, other.spock?]).include?([true, true]) ||
      [scissors?].product([other.paper?, other.lizard?]).include?([true, true]) ||
      [spock?].product([other.rock?, other.scissors?]).include?([true, true]) ||
      [lizard?].product([other.paper?, other.spock?]).include?([true, true])
  end

  def <(other)
    [rock?].product([other.paper?, other.spock?]).include?([true, true]) ||
      [paper?].product([other.lizard?, other.scissors?]).include?([true, true]) ||
      [scissors?].product([other.rock?, other.spock?]).include?([true, true]) ||
      [spock?].product([other.lizard?, other.paper?]).include?([true, true]) ||
      [lizard?].product([other.rock?, other.scissors?]).include?([true, true])
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
  DIVIDER = "-" * 33

  attr_accessor :human, :computer

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    system 'clear'
    puts "Welcome to Rock, Paper, Scissors!"
    puts "First to #{Score::WINNING_SCORE} wins."
    puts DIVIDER
  end

  def display_goodbye_message
    puts "Thanks for playing!"
  end

  def display_moves
    moves = "#{human.name} chose: #{human.move}; "
    moves << "#{computer.name} chose: #{computer.move}"
    puts moves
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won the hand!"
    elsif human.move < computer.move
      puts "#{computer.name} won the hand."
    else
      puts "It's a draw."
    end
  end

  def display_scores
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts DIVIDER
  end

  def display_game_board
    display_welcome_message
    display_scores
  end

  def tally_points
    if human.move > computer.move
      human.score.add_point
    elsif human.move < computer.move
      computer.score.add_point
    end
  end

  def game_over?
    "#{human.score}".to_i == Score::WINNING_SCORE ||
      "#{computer.score}".to_i == Score::WINNING_SCORE
  end

  def display_game_winner
    if human.score == Score::WINNING_SCORE
      puts "#{human.name} won the game!"
    elsif computer.score == Score::WINNING_SCORE
      puts "#{computer.name} won the game."
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Up for another game? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Please answer y or n."
    end
    answer == 'y' ? true : false
  end

  def forfeit?
    answer = nil
    loop do
      puts "Press <enter> to continue or Forfeit (f)"
      answer = gets.downcase
      break if ["\n", "f\n"].include?(answer)
      puts "Invalid. Please press <enter> or f"
    end
    answer == "f\n" ? true : false
  end

  def new_hand
    loop do
      display_game_board
      @human.choose
      @computer.choose
      tally_points
      display_game_board
      display_moves
      display_winner
      break if game_over? || forfeit?
    end
  end

  def new_game
    loop do
      @human.set_score
      @computer.set_score
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
