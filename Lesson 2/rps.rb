class Move
  MENU = { 1 => 'Rock', 2 => 'Paper', 3 => 'Scissors', 4 => 'Lizard',
             5 => 'Spock' }
  attr_reader :value, :win_against

  def >(other)
    win_against.include?(other.value)
  end

  def <(other)
    other.win_against.include?(value)
  end

  def to_s
    @value
  end
end

class Rock < Move
  def initialize
    @value = 'Rock'
    @win_against = ['Scissors', 'Lizard']
  end
end

class Paper < Move
  def initialize
    @value = 'Paper'
    @win_against = ['Rock', 'Spock']
  end
end

class Scissors < Move
  def initialize
    @value = 'Scissors'
    @win_against = ['Paper', 'Lizard']
  end
end

class Lizard < Move
  def initialize
    @value = 'Lizard'
    @win_against = ['Spock', 'Paper']
  end
end

class Spock < Move
  def initialize
    @value = 'Spock'
    @win_against = ['Scissors', 'Rock']
  end
end

class RPSGame
  MAX_SCORE = 5
  attr_accessor :human, :computer

  @@history = []

  def initialize
    system('clear') || system('cls')
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "\nWelcome to Rock, Paper, Scissors, Lizard & Spock!"
    puts "\nFirst player to reach #{MAX_SCORE} wins!"
  end

  def display_goodbye_message
    puts "\nThanks for playing Rock, Paper, Scissors, Lizard & Spock! Goodbye!"
  end

  def display_choices
    puts "\n   #{human.name} chose #{human.move}"
    puts "   #{computer.name} chose #{computer.move}"
  end

  def tension
    puts("\n   1..")
    sleep(0.5)
    puts('   2..')
    sleep(0.5)
    puts('   3...')
    sleep(0.5)
    puts '   SHOOT!'
  end

  def human_wins?
    human.move > computer.move
  end

  def computer_wins?
    computer.move > human.move
  end

  def update_scores
    if human_wins?
      human.score += 1
      @@history << "Win"
    elsif computer_wins?
      computer.score += 1
      @@history << "Loss"
    else
      @@history << "Tie"
    end
  end

  def max_score_reached?
    human.score == MAX_SCORE || computer.score == MAX_SCORE
  end

  def display_winner
    puts "\n   #{human.name} won!" if human_wins?
    puts "\n   #{computer.name} won!" if computer_wins?
    puts "\n   It's a tie!" if !human_wins? && !computer_wins?
  end

  def display_scores
    puts "\n#{human.name}: #{human.score}  #{computer.name}: #{computer.score}"
  end

  def play_again?
    answer = ''
    loop do
      print "Would you like to play again? (Y/N) "
      answer = gets.chomp.upcase
      break if ['Y', 'N'].include?(answer)
      puts "Please enter Y or N"
    end
    answer == 'Y'
  end

  def main_loop
    system('clear') || system('cls')
    display_scores
    human.choose
    tension
    computer.choose
    display_choices
    update_scores
    display_winner
    sleep(1.5)
  end

  def play
    loop do
      main_loop
      break if max_score_reached?
    end
    display_scores
    display_goodbye_message
  end

  def self.history
    system('clear') || system('cls')
    history_title_strip
    @@history.each_slice(3) { |move| show_line(move) }
  end

  def self.move_history
    @@history
  end

  def self.add_to_history(move)
    @@history << move
  end

  class << self
    def history_title_strip
      puts "\nGAME HISTORY:"
      puts "Player".ljust(10) + "Comp".ljust(10) + "P Move".ljust(10) +
           "C Move".ljust(10) + "W/L".ljust(10)
      puts "-" * 50
    end

    def short_names(move)
      move[0][0][0..8].ljust(10) + move[1][0][0..8].ljust(10)
    end

    def show_line(move)
      puts short_names(move) + move[0][1].ljust(10) + move[1][1].ljust(10) +
           move[2].ljust(10)
    end
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def move_history
    RPSGame.move_history.each_slice(3)
  end

  def history
    system('clear') || system('cls')
    moves = move_history
    puts
    puts "PLAYER HISTORY:"
    puts "Player".ljust(10) + "Move".ljust(10) + "W/L".ljust(10)
    puts "-" * 30
    moves.each do |move|
      puts move[0][0][0..8].ljust(10) + move[0][1].ljust(10) + move[2]
    end
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      print "\nWhat's your name?  "
      n = gets.chomp
      break unless n.strip.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choice_menu
    puts "\n   Please choose from the following: "
    puts "   1) Rock"
    puts "   2) Paper"
    puts "   3) Scissors"
    puts "   4) Lizard"
    puts "   5) Spock"
    puts "   6) Player History"
    puts "   7) Game History"
  end

  def print_history_or_invalid(choice)
    history if choice == 6
    RPSGame.history if choice == 7
    puts "Sorry, invalid choice." if ![6, 7].include?(choice)
  end

  def choose
    choice = nil
    loop do
      choice_menu
      print "=> "
      choice = gets.chomp.to_i
      break if Move::MENU.keys.include?(choice)
      print_history_or_invalid(choice)
    end
    self.move = Object.const_get(Move::MENU[choice]).new
    RPSGame.add_to_history([name, move.to_s])
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'C3PO', 'Hal', 'Chappie', 'Number 5'].sample
  end

  def choose
    case name
    when 'R2D2' 
      choice = r2d2_logic
    when 'C3PO'
      choice = c3po_logic
    when 'Hal'
      choice = hal_logic
    when 'Chappie'
      choice = chappie_logic
    when 'Number 5'
      choice = number_5_logic
    end
    self.move = Object.const_get(choice).new
    RPSGame.add_to_history([name, move.to_s])
  end

  private

  def r2d2_logic
    'Rock'
  end

  def c3po_logic
    ['Rock', 'Paper', 'Scissors'].sample
  end

  def hal_logic
    case rand(99)
    when 0..45 then "Scissors"
    when 46..70 then "Lizard"
    when 71..85 then "Spock"
    else
      "Rock"
    end
  end

  def chappie_logic
    case rand(99)
    when 0..20 then "Rock"
    when 21..40 then "Paper"
    when 41..60 then "Lizard"
    when 61-99 then "Spock"
    else
      "Scissors"
    end
  end

  def number_5_logic
    ['Spock', 'Lizard'].sample
  end
end

RPSGame.new.play
RPSGame.history
