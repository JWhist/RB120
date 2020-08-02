class Board
  attr_accessor :square

  def initialize
    create_new
  end

  def create_new
    @square = {}
    (1..9).each { |i| @square[i] = Square.new }
  end

  def show
    puts "        |        |"
    puts "        |        |"
    puts "    #{@square[7]}   |    #{@square[8]}   |    #{@square[9]}"
    puts "        |        |"
    puts "        |        |"
    puts "--------+--------+--------"
    puts "        |        |"
    puts "        |        |"
    puts "    #{square[4]}   |    #{square[5]}   |    #{square[6]}"
    puts "        |        |"
    puts "        |        |"
    puts "--------+--------+--------"
    puts "        |        |"
    puts "        |        |"
    puts "    #{square[1]}   |    #{square[2]}   |    #{square[3]}"
    puts "        |        |"
    puts "        |        |"
  end

  def full?
    self.square.values.all? { |marker| marker.mark != ' ' }
  end

  def empty_squares
    self.square.select { |sq, marker| marker.mark == ' ' }.keys
  end
end

class Square
  attr_accessor :mark

  def initialize
    @mark = ' '
  end

  def empty?
    @mark == ' '
  end

  def mark
    @mark
  end

  def to_s
    @mark
  end
end

class Player
  P_MARKER = 'X'
  attr_reader :name

  def initialize
    @name = new_name
  end

  def new_name
    answer = ''
    loop do
      print "What is your name?  "
      answer = gets.chomp
      break if answer.strip != ''
      puts "Please enter a name"
    end
    @name = answer
  end

  def mark_square(board)
    choice = ''
    loop do
      print "Please choose a square:  "
      choice = gets.chomp.to_i
      break if board.empty_squares.include?(choice)
      puts "Please make a valid selection."
    end
    board.square[choice].mark = P_MARKER
  end
end

class Computer
  WIN_KEY = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
             [1, 4, 7], [2, 5, 8], [3, 6, 9],
             [1, 5, 9], [3, 5, 7]]
  C_MARKER = 'O'
  attr_accessor :difficulty

  def initialize
    set_difficulty
  end

  def set_difficulty
    loop do
      puts "Please choose difficulty: "
      puts "1) Easy"
      puts "2) Normal"
      puts "3) Raging Inferno"
      @difficulty = gets.chomp.to_i
      break if [1, 2, 3].include?(@difficulty)
      puts "Please choose 1, 2, or 3"
    end
  end

  def winner(board)
    WIN_KEY.each do |line|
      if board.square.values_at(*line).count { |sq| is_player?(sq) } == 3
        return 'Player'
      elsif board.square.values_at(*line).count { |sq| is_computer?(sq) } == 3
        return 'Computer'
      end
    end
    false
  end

  def mark_square(board)
    case @difficulty
    when 1 then ai_easy(board)
    when 2 then ai_med(board)
    when 3 then ai_hard(board)
    end
  end

  private

  def is_player?(sq)
    sq.mark == Player::P_MARKER
  end

  def is_computer?(sq)
    sq.mark == C_MARKER
  end

  def ai_easy(board)
    board.square[board.empty_squares.sample].mark = C_MARKER
  end

  def ai_med(board)
    return if find_win?(board)
    return if play_defense?(board)
    return if take_middle_square?(board)
    ai_easy(board)
  end

  def ai_hard(board) #primary minimax call
    best_score = -800_000 # these are arbitrary #s, must be higher/lower than
    move = nil            # the scores being returned in the score method
    board.empty_squares.each do |n|
      board.square[n].mark = C_MARKER
      score = minimax(board, false) # false --> other persons turn, minimizer
      board.square[n].mark = ' '
      if score > best_score
        best_score = score
        move = n
      end
    end
  board.square[move].mark = C_MARKER
  end

  def find_win?(board)
  temp = nil
  WIN_KEY.each do |line|  # Look for a win on the current move
    if board.square.values_at(*line).count { |sq| is_computer?(sq) } == 2
      temp = line.select { |n| board.square[n].mark != C_MARKER }.pop
      if board.empty_squares.include?(temp)
        board.square[temp].mark = C_MARKER
        return true
      end
    end
  end
  false
  end

  def play_defense?(board)
    temp = nil
    WIN_KEY.each do |line|  # Stop player from winning on the next move
      if board.square.values_at(*line).count { |sq| is_player?(sq) } == 2
        temp = line.select { |n| board.square[n].mark != Player::P_MARKER }.pop
        if board.empty_squares.include?(temp)
          board.square[temp].mark = C_MARKER
          return true
        end
      end
    end
    false
  end

  def take_middle_square?(board)
    if board.empty_squares.include?(5) # Take middle square if open
      board.square[5].mark = C_MARKER
      return true
    end
    false
  end

  def score(board) # Used by minimax algo in hard difficulty mode
    WIN_KEY.each do |line|
      if board.square.values_at(*line).count { |sq| is_player?(sq) } == 3
        return -1 # --> player wins is minimize result == BAD
      elsif board.square.values_at(*line).count { |sq| is_computer?(sq) } == 3
        return 1 # --> we win is maximize result == GOOD
      end
    end
    0 # --> tie is neutral result
  end

  def board_full?(board)
    board.empty_squares.empty?
  end

  def minimax(board, compturn) # Used in hard difficulty mode
    return score(board) if winner(board) != false || board_full?(board)
    if compturn == true  # --> on our turn maximize score (look for win)
      best_score = -800_000
      board.empty_squares.each do |n|
        board.square[n].mark = C_MARKER
        position_score = minimax(board, false)
        board.square[n].mark = ' '
        best_score = [position_score, best_score].max
      end
    else
      best_score = 800_000 # -> on opponent turn minimize score (look for loss)
      board.empty_squares.each do |n|
        board.square[n].mark = Player::P_MARKER
        position_score = minimax(board, true)
        board.square[n].mark = ' '
        best_score = [position_score, best_score].min
      end
    end
    best_score
  end
end

class Scoreboard
  attr_accessor :player_score, :computer_score

  def initialize
    resetscores
  end

  def resetscores
    @player_score = 0
    @computer_score = 0
  end

  def update(computer, board)
    @player_score += 1 if computer.winner(board) == 'Player'
    @computer_score += 1 if computer.winner(board) == 'Computer'
  end

  def show
    puts "Player is #{Player::P_MARKER}.  Computer is #{Computer::C_MARKER}."
    puts "SCORE: Player: #{@player_score} CPU: #{@computer_score}"
  end
end

class TTTGame
  MAX_SCORE = 5
  attr_accessor :player, :computer
  attr_reader :scoreboard, :board

  def initialize
    welcome
    @player = Player.new
    @computer = Computer.new
    @board = Board.new
    @scoreboard = Scoreboard.new
  end

  def welcome
    system 'clear' || system(cls)
    puts "Welcome to TIC TAC TOE"
  end

  def goodbye
    puts "Sometimes the only way to win, is not to play at all"
  end

  def max_score_reached?
    scoreboard.player_score == MAX_SCORE ||
    scoreboard.computer_score == MAX_SCORE
  end

  def winner?(board)
    player_wins?(board) || computer_wins?(board)
  end

  def player_wins?(board)
    computer.winner(board) == 'Player'
  end

  def computer_wins?(board)
    computer.winner(board) == 'Computer'
  end

  def show_winner(computer, board)
    if computer.winner(board) == false
      puts "It's a tie!" 
    else
      puts "#{computer.winner(board)} wins!"
    end
  end

  def play_again?
    again = ''
    loop do
      puts "Play again? Y/N?"
      again = gets.chomp.downcase
      break if again == 'y' || again == 'n'
      puts "Please enter Y or N"
    end
    again == 'y' ? true : false
  end

  def clearscreen
    system('clear') || system('cls')
  end

  def main_display
    clearscreen
    scoreboard.show
    board.show
  end

  def reset
    board.create_new
    scoreboard.resetscores
  end

  def play
    loop do
      loop do
        loop do
          main_display
          player.mark_square(board)
          main_display
          break if winner?(board) || board.full?
          computer.mark_square(board)
          main_display
          break if winner?(board) || board.full?
        end
        sleep(1)
        scoreboard.update(computer, board)
        main_display
        show_winner(computer, board)
        break if max_score_reached?
        board.create_new
      end
      break unless play_again?
      reset
    end
    goodbye
  end
end

TTTGame.new.play