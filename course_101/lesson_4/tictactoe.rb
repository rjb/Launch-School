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
  if win_oppotunity?(board)
    board[find_opportunity_square(board)] = COMPUTER_MARKER
  elsif square_at_risk?(board)
    board[find_at_risk_square(board)] = COMPUTER_MARKER
  else
    board[empty_squares(board).sample] = COMPUTER_MARKER
  end
end

def square_at_risk?(board)
  !!find_at_risk_square(board)
end

# finds at risk square when two in a row
# for any at risk, use something like:
# if board.values_at(*line).count(PLAYER_MARKER) == 2
# board.select { |square, marker| line.include?(square) && marker == INITIAL_MARKER}.keys.first
def find_at_risk_square(board)
  WINNING_LINES.each do |line|
    if board.values_at(*line) == [PLAYER_MARKER, PLAYER_MARKER, INITIAL_MARKER]
      return line[2]
    elsif board.values_at(*line) == [INITIAL_MARKER, PLAYER_MARKER, PLAYER_MARKER]
      return line[0]
    end
  end
  nil
end

def win_oppotunity?(board)
  !!find_opportunity_square(board)
end

def find_opportunity_square(board)
  WINNING_LINES.each do |line|
    if board.values_at(*line).count(COMPUTER_MARKER) == 2
      return board.select { |square, marker| line.include?(square) && marker == INITIAL_MARKER }.keys.first
    end
  end
  nil
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

loop do
  score = initialize_score
  
  loop do
    board = initialize_board

    loop do
      display_board(board, score)

      player_places_piece!(board)
      break if someone_won?(board) || board_full?(board)
      
      computer_places_piece!(board)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board, score)
    
    if someone_won?(board)
      winner = detect_winner(board)

      tally_score(winner, score)
      display_board(board, score)

      prompt("#{winner} won!")
    else
      prompt("It's a tie.")
    end

    if game_over?(score)
      prompt("Game over! #{detect_game_winner(score)} won the gam!")
      break
    end

    prompt("Ready? Press <enter> or forfeit (f)")
    break if gets.chomp.downcase.start_with?('f')
  end

  prompt("Play another game? (y or n)")
  break unless gets.chomp.downcase.start_with?('y')
end

prompt("Thanks for playing Tic Tac Toe!")
