require 'pry'

# Board
class Board
  def initialize
    @squares = {}
    reset
  end

  def someone_won?
    !!winning_marker
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

  def winning_marker(lines, count)
    lines.each do |line|
      sqrs = @squares.values_at(*line)
      return sqrs.first.marker if identical_markers?(sqrs, count)
    end
    nil
  end

  def identical_markers?(squares, count)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.count != count
    markers.min == markers.max
  end
end

# 3x3 board
class ThreeByThreeBoard < Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]

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

  def winning_marker
    WINNING_LINES.each do |line|
      sqrs = @squares.values_at(*line)
      return sqrs.first.marker if three_idential_markers?(sqrs)
    end
    nil
  end

  def open_square(marker)
    WINNING_LINES.each do |line|
      marker_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == marker
      end

      open_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == Square::INITIAL_MARKER
      end

      if marker_count == 2 && open_count == 1
        return line.find { |i| "#{@squares[i]}" == Square::INITIAL_MARKER }
      end
    end

    nil
  end

  private

  def three_idential_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.count != 3
    markers.min == markers.max
  end
end

# 5x5 board
class FiveByFiveBoard < Board
  WINNING_LINES = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15],
                   [16, 17, 18, 19, 20], [21, 22, 23, 24, 25], [1, 6, 11, 16, 21],
                   [2, 7, 12, 17, 22], [3, 8, 13, 18, 23], [4, 9, 14, 19, 24],
                   [5, 10, 15, 20, 25], [1, 7, 13, 19, 25], [5, 9, 13, 17, 21]]

  def reset
    (1..25).each { |i| @squares[i] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts '  1  |  2  |  3  |  4  |  5'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  |  #{@squares[4]}  |  #{@squares[5]}"
    puts '     |     |     |     |'
    puts '-----+-----+-----+-----+-----'
    puts '  6  |  7  |  8  |  9  |  10'
    puts "  #{@squares[6]}  |  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  |  #{@squares[10]}"
    puts '     |     |     |     |'
    puts '-----+-----+-----+-----+-----'
    puts '  11 |  12 |  13 |  14 |  15'
    puts "  #{@squares[11]}  |  #{@squares[12]}  |  #{@squares[13]}  |  #{@squares[14]}  |  #{@squares[15]}"
    puts '     |     |     |     |'
    puts '-----+-----+-----+-----+-----'
    puts '  16 |  17 |  18 |  19 |  20'
    puts "  #{@squares[16]}  |  #{@squares[17]}  |  #{@squares[18]}  |  #{@squares[19]}  |  #{@squares[20]}"
    puts '     |     |     |     |'
    puts '-----+-----+-----+-----+-----'
    puts '  21 |  22 |  23 |  24 |  25'
    puts "  #{@squares[21]}  |  #{@squares[22]}  |  #{@squares[23]}  |  #{@squares[24]}  |  #{@squares[25]}"
    puts '     |     |     |     |'
  end
  # rubocop:enable Metrics/AbcSize

  def winning_marker
    super(WINNING_LINES, 5)
  end

  def open_square(marker)
    WINNING_LINES.each do |line|
      marker_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == marker
      end

      open_count = @squares.values_at(*line).count do |sqr|
        "#{sqr}" == Square::INITIAL_MARKER
      end

      if marker_count == 4 && open_count == 1
        return line.find { |i| "#{@squares[i]}" == Square::INITIAL_MARKER }
      end
    end

    nil
  end

  private

  def labelize_squares
    results = {}
    (1..25).each do |i|
      padding = i < 10 ? '' : ' '
      results[i] = "#{@squares[i]}" == ' ' ? i : "#{@squares[i]}#{padding}"
    end
    results
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
    @board = FiveByFiveBoard.new
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
