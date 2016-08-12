require 'pry'

# Board
class Board
  def initialize
    @squares = {}
    reset
  end

  def reset
    count = self.class::SIZE
    (1..(count*count)).each { |i| @squares[i] = Square.new }
  end

  def draw
    step = 0
    (1..self.class::SIZE).each do |row|
      line = ''
      (1..self.class::SIZE).each do |i|
        square_num = i + step
        label = (self.class::SIZE > 3 ? "#{square_num}" : ' ') + (square_num < 10 ? ' ' : '')
        line += "  #{label} |"
      end
      puts line[0...-1]

      line = ''
      (1..self.class::SIZE).each do |i|
        line += '  '
        line += "#{@squares[i + step]}"
        line += '  |' unless i == self.class::SIZE
      end
      puts line

      line = ''
      (self.class::SIZE - 1).times { |i| line += "     |" }
      puts line

      unless row == self.class::SIZE
        line = ''
        (self.class::SIZE).times { line += "-----+" }
        puts line[0...-1]
      end

      step += self.class::SIZE
    end
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.select { |_, square| square.unmarked? }.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def middle_square_open?
    "#{@squares[middle_square]}" == Square::INITIAL_MARKER
  end

  def win_opportunity?(marker)
    open_square(marker)
  end

  def middle_square
    (@squares.length / 2) + 1
  end

  def open_square(marker)
    self.class::WINNING_LINES.each do |line|
      marker_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == marker
      end

      open_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == Square::INITIAL_MARKER
      end

      if marker_count == self.class::SIZE - 1 && open_count == 1
        return line.find { |i| "#{@squares[i]}" == Square::INITIAL_MARKER }
      end
    end
    nil
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    self.class::WINNING_LINES.each do |line|
      sqrs = @squares.values_at(*line)
      return sqrs.first.marker if identical_markers?(sqrs)
    end
    nil
  end

  private

  def identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.count != self.class::SIZE
    markers.min == markers.max
  end
end

# 3x3 board
class SmallBoard < Board
  SIZE = 3
  MAX_PLAYER_COUNT = 2
  WINNING_LINES = [
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 5, 9], [3, 5, 7]
  ]
end

# 5x5 board
class MediumBoard < Board
  SIZE = 5
  WINNING_LINES = [
    [1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20], [21, 22, 23, 24, 25], [1, 6, 11, 16, 21],
    [2, 7, 12, 17, 22], [3, 8, 13, 18, 23], [4, 9, 14, 19, 24],
    [5, 10, 15, 20, 25], [1, 7, 13, 19, 25], [5, 9, 13, 17, 21]
  ]
end

# 9x9 board
class LargeBoard < Board
  SIZE = 9
  WINNING_LINES = [
    [1, 2, 3, 4, 5, 6, 7, 8, 9], [10, 11, 12, 13, 14, 15, 16, 17, 18],
    [19, 20, 21, 22, 23, 24, 25, 26, 27], [28, 29, 30, 31, 32, 33, 34, 35, 36],
    [37, 38, 39, 40, 41, 42, 43, 44, 45], [46, 47, 48, 49, 50, 51, 52, 53, 54],
    [55, 56, 57, 58, 59, 60, 61, 62, 63], [64, 65, 66, 67, 68, 69, 70, 71, 72],
    [73, 74, 75, 76, 77, 78, 79, 80, 81], [1, 10, 19, 28, 37, 46, 55, 64, 73],
    [2, 11, 20, 29, 38, 47, 56, 65, 74], [3, 12, 21, 30, 39, 48, 57, 66, 75],
    [4, 13, 22, 31, 40, 49, 58, 67, 76], [5, 14, 23, 32, 41, 50, 59, 68, 77],
    [6, 15, 24, 33, 42, 51, 60, 69, 78], [7, 16, 25, 34, 43, 52, 61, 70, 79],
    [8, 17, 26, 35, 44, 53, 62, 71, 80], [9, 18, 27, 36, 45, 54, 63, 72, 81],
    [1, 11, 21, 31, 41, 51, 61, 71, 81], [9, 17, 25, 33, 41, 49, 57, 65, 73]
  ]
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
  attr_accessor :name, :marker
  attr_reader :score

  def initialize
    set_name
  end

  def set_name
    n = ''
    loop do
      puts 'What is your name?'
      n = gets.chomp
      break unless n.empty?
      puts 'Invalid name.'
    end
    self.name = n
  end

  def give_point
    @score.add_point
  end

  def reset_score
    @score = Score.new
  end
end

# Computer
class Computer < Player
  NAMES = [
    'HAL',
    'C-3PO',
    'Number5',
    'GERTY',
    'RobotB-9',
    'Rosie'
  ]

  def set_name
    self.name = NAMES.sample
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

  def ==(other)
    @value == other
  end

  def to_s
    "#{@value}"
  end
end

# TTTGame
class TTTGame
  # Options: player, computer, choose
  FIRST_PLAYER = 'choose'
  MARKERS = %w(X O)

  attr_reader :board, :human, :computer

  def initialize
    @board = LargeBoard.new
    @human = Player.new
    @computer = Computer.new
    set_markers
  end

  def play
    loop do
      reset
      reset_score
      clear
      new_game
      display_match_result
      break unless play_again?
    end
    display_goodbye_message
  end

  def new_game
    loop do
      set_first_player_name
      display_board
      alternate_moves
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

  def display_first_player_message
    puts "#{@first_player_name} goes first"
  end

  def display_goodbye_message
    puts 'Thanks for playing!'
  end

  def display_board
    display_welcome_message
    display_first_player_message
    puts "#{human.name} (#{human.marker}): #{human.score} | " \
           "#{computer.name} (#{computer.marker}): #{computer.score}"
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def alternate_moves
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def set_current_marker
    @current_marker =
      case FIRST_PLAYER
      when 'player'
        human.marker
      when 'computer'
        computer.marker
      when 'choose'
        choose_marker
      end
  end

  def set_first_player_name
    @first_player_name =
      case @current_marker
      when human.marker
        human.name
      when computer.marker
        computer.name
      end
  end

  def choose_marker
    m = ''
    loop do
      puts "Who goes first, Player (p) or Computer (c)?"
      m = gets.chomp.downcase
      break if ['p', 'c'].include?(m)
      puts 'Invalide choice.'
    end
    m == 'p' ? human.marker : computer.marker
  end

  def set_markers
    set_human_marker
    set_computer_marker
  end

  def set_human_marker
    m = ''
    loop do
      puts "Pick a marker (#{choices_to_english(MARKERS)}):"
      m = gets.chomp.capitalize
      break unless m.empty? || !MARKERS.include?(m)
      puts 'Invalid marker.'
    end
    human.marker = m
  end

  def set_computer_marker
    computer.marker = MARKERS.select { |m| m != "#{human.marker}" }.sample
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

  def choices_to_english(choices)
    count = choices.count

    if count == 1
      "#{choices.first}"
    elsif count == 2
      "#{choices.join(' or ')}"
    else
      "#{choices[0...-1].join(', ')}, or #{choices.last}"
    end
  end

  def human_moves
    puts "Choose a square (#{choices_to_english(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts 'Please choose an unmarked square.'
    end
    board[square] = human.marker
  end

  def computer_moves
    square = if board.win_opportunity?(computer.marker)
               board.open_square(computer.marker)
             elsif board.win_opportunity?(human.marker)
               board.open_square(human.marker)
             elsif board.middle_square_open?
               board.middle_square
             else
               board.unmarked_keys.sample
             end
    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
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
    set_current_marker
    clear
  end

  def reset_score
    human.reset_score && computer.reset_score
  end
end

game = TTTGame.new
game.play
