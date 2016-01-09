FIRST_PLAYER = 'Choose' # Choose, Player, or Computer
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_SCORE = 5
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

def prompt(message)
  puts "=> #{message}"
end

def display_board(board, score)
  system 'clear'
  puts "Welcome to Tic Tac Toe! First to #{WINNING_SCORE} wins."
  puts "----------------------------------------"
  puts "Player  |  Computer".rjust(30)
  puts "  #{PLAYER_MARKER}     |     #{COMPUTER_MARKER}".rjust(26)
  puts "  #{score[:player]}     |     #{score[:computer]}".rjust(26)
  puts "----------------------------------------"
  puts ""
  puts "     |     |"
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}"
  puts "     |     |"
  puts ""
end

def initialize_score
  { player: 0, computer: 0 }
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def joinor(board, delimiter = ', ', conjunction = 'or')
  board[-1] = "#{conjunction} #{board.last}" if board.size > 1
  board.join(delimiter)
end

def valid_player?(player)
  player == "Player" || player == "Computer"
end

def alternate(current_player)
  if current_player == "Computer"
    "Player"
  else
    "Computer"
  end
end

def play_piece!(board, current_player)
  case current_player
  when "Player"
    player_places_piece!(board)
  when "Computer"
    computer_places_piece!(board)
  end
end

def player_places_piece!(board)
  square = ''
  loop do
    prompt("Choose a square (#{joinor(empty_squares(board))}):")
    square = gets.chomp.to_i
    break if empty_squares(board).include?(square)
    prompt("Sorry, that is not a valid choice.")
  end

  board[square] = PLAYER_MARKER
end

def computer_places_piece!(board)
  square = if square_at_risk?(WINNING_LINES, board, COMPUTER_MARKER)
             find_at_risk_square(WINNING_LINES, board, COMPUTER_MARKER)
           elsif square_at_risk?(WINNING_LINES, board, PLAYER_MARKER)
             find_at_risk_square(WINNING_LINES, board, PLAYER_MARKER)
           elsif middle_square_available?(board)
             middle_square_position(board)
           else
             empty_squares(board).sample
           end

  board[square] = COMPUTER_MARKER
end

def square_at_risk?(winning_lines, board, marker)
  !!find_at_risk_square(winning_lines, board, marker)
end

def find_at_risk_square(winning_lines, board, marker)
  winning_lines.each do |line|
    if board.values_at(*line).count(marker) == 2
      return board.select { |sqr, mkr| line.include?(sqr) && mkr == INITIAL_MARKER }.keys.first
    end
  end
  nil
end

def middle_square_available?(board)
  board[middle_square_position(board)] == INITIAL_MARKER
end

def middle_square_position(board)
  board.keys[board.keys.size / 2]
end

def board_full?(board)
  empty_squares(board).empty?
end

def someone_won?(board)
  !!detect_winner(board)
end

def detect_winner(board)
  WINNING_LINES.each do |line|
    if board.values_at(*line).count(PLAYER_MARKER) == 3
      return "Player"
    elsif board.values_at(*line).count(COMPUTER_MARKER) == 3
      return "Computer"
    end
  end
  nil
end

def tally_score(winner, score)
  return score[winner.downcase.to_sym] += 1 if winner
  nil
end

def game_over?(score)
  score[:player] == WINNING_SCORE || score[:computer] == WINNING_SCORE
end

def detect_game_winner(score)
  if score[:player] == WINNING_SCORE
    return "Player"
  elsif score[:computer] == WINNING_SCORE
    return "Computer"
  end
  nil
end

def determine_first_player(player_switch)
  case FIRST_PLAYER
  when 'Choose'
    choose_first_player
  else
    FIRST_PLAYER
  end
end

def choose_first_player
  player = ''
  loop do
    prompt("Who's first? Player (p) or Computer (c)")
    player = case gets.chomp.downcase
             when 'p'
               'Player'
             when 'c'
               'Computer'
             end
    break if valid_player?(player)
    prompt("Please choose a valid player")
  end
  player
end

loop do
  score = initialize_score

  loop do
    board = initialize_board
    display_board(board, score)
    current_player = determine_first_player(FIRST_PLAYER)

    loop do
      display_board(board, score)
      play_piece!(board, current_player)
      current_player = alternate(current_player)

      break if someone_won?(board) || board_full?(board)
    end

    if someone_won?(board)
      winner = detect_winner(board)
      tally_score(winner, score)
      display_board(board, score)

      prompt("#{winner} won!")
    else
      prompt("It's a tie.")
    end

    if game_over?(score)
      prompt("Game over! #{detect_game_winner(score)} won the game!")
      break
    end

    prompt("Ready? Press <enter> or forfeit (f)")
    break if gets.chomp.downcase.start_with?('f')
  end

  prompt("Play another game? (y or n)")
  break unless gets.chomp.downcase.start_with?('y')
end

prompt("Thanks for playing Tic Tac Toe!")
