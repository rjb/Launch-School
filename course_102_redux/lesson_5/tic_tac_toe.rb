require 'pry'
# Board
class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |i| @squares[i] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop:enable Metrics/AbcSize

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.select { |_, square| square.unmarked? }.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_idential_markers?(squares)
    end
    nil
  end

  def at_risk_square(line, marker)
    count = @squares.values_at(*line).count { |square| "#{square}" == marker }
    if count == 2
      square = @squares.select do |k, v|
        line.include?(k) && "#{v}" == Square::INITIAL_MARKER 
      end
      square.keys.first
    else
      nil
    end
  end

  private

  def three_idential_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.count != 3
    markers.min == markers.max
  end
end

# Square
class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

# Player
class Player
  attr_reader :marker, :score

  def initialize(marker)
    @marker = marker
  end

  def give_point
    @score.add_point
  end

  def reset_score
    @score = Score.new
  end
end

# Score
class Score
  INTIAL_SCORE = 0
  WINNING_SCORE = 5

  def initialize
    @value = INTIAL_SCORE
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

# TTTGame
class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play
    loop do
      reset
      reset_score
      clear
      display_welcome_message
      new_game
      display_match_result
      break unless play_again?
    end
    display_goodbye_message
  end

  def new_game
    loop do
      display_board
      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end
      clear
      award_point
      display_result
      break if game_over? || forfeit?
      reset
    end
  end

  private

  def clear
    system 'clear'
  end

  def display_welcome_message
    puts "Welcome to Tick Tack Toe! First to #{Score::WINNING_SCORE} wins."
  end

  def display_goodbye_message
    puts 'Thanks for playing!'
  end

  def display_board
    puts "You're #{human.marker}. Computer is #{computer.marker}."
    puts "You: #{human.score} Computer: #{computer.score}"
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def award_point
    case board.winning_marker
    when human.marker
      human.give_point
    when computer.marker
      computer.give_point
    end
  end

  def display_result
    display_board

    case board.winning_marker
    when human.marker
      puts 'You won!'
    when computer.marker
      puts 'Computer won!'
    else
      puts "It's a tie."
    end
  end

  def display_match_result
    case Score::WINNING_SCORE
    when human.score
      puts 'You won the match!'
    when computer.score
      puts 'Computer won the match!'
    end
  end

  def choices_string
    length = board.unmarked_keys.count
    keys = board.unmarked_keys

    if length == 1
      "#{keys.first}"
    elsif length == 2
      "#{keys.join(' ')}"
    else
      "#{keys[0...-1].join(', ')}, or #{keys.last}"
    end
  end

  def human_moves
    puts "Choose a square (#{choices_string}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts 'Please choose an unmarked square.'
    end
    board[square] = human.marker
  end

  def computer_moves
    square = nil
    Board::WINNING_LINES.each do |line|
      square = board.at_risk_square(line, HUMAN_MARKER)
      break if square
    end
    square = board.unmarked_keys.sample if !square
    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play another match? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts 'Enter a valid choice.'
    end
    answer == 'y'
  end

  def forfeit?
    answer = nil
    loop do
      puts 'Continue (c) or forfeit (f)?'
      answer = gets.chomp.downcase
      break if %w(c f).include?(answer)
      puts 'Enter a valid choice.'
    end
    answer == 'f'
  end

  def game_over?
    human.score == Score::WINNING_SCORE ||
      computer.score == Score::WINNING_SCORE
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def reset_score
    human.reset_score && computer.reset_score
  end
end

game = TTTGame.new
game.play
