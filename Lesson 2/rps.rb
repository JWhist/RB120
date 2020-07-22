class Move
  VALUES = ['Rock', 'Paper', 'Scissors', 'Lizard', 'Spock']
  attr_reader :value

  def initialize(value)
    @value = value
  end

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
  attr_reader :win_against

  def initialize
    super('Rock')
    @win_against = ['Scissors', 'Lizard']
  end
end

class Paper < Move
  attr_reader :win_against

  def initialize
    super('Paper')
    @win_against = ['Rock', 'Spock']
  end
end

class Scissors < Move
  attr_reader :win_against

  def initialize
    super('Scissors')
    @win_against = ['Paper', 'Lizard']
  end
end

class Lizard < Move
  attr_reader :win_against

  def initialize
    super('Lizard')
    @win_against = ['Spock', 'Paper']
  end
end

class Spock < Move
  attr_reader :win_against

  def initialize
    super('Spock')
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
  end

  def display_goodbye_message
    puts "\nThanks for playing Rock, Paper, Scissors, Lizard & Spock! Goodbye!"
  end

  def display_choices
    puts "\n#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def tension
  puts('1..')
  sleep(0.5)
  puts('2..')
  sleep(0.5)
  puts('3...')
  sleep(0.5)
  puts 'SHOOT!'
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
    puts "\n#{human.name} won!" if human_wins?
    puts "\n#{computer.name} won!" if computer_wins?
    puts "\nIt's a tie!" if !human_wins? && !computer_wins?
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
    RPSGame.move_history.select { |pair| pair[0] == name }
  end

  def history
    moves = move_history
    puts
    puts "PLAYER HISTORY:"
    puts "Player".ljust(10) + "Move".ljust(10)
    puts "-" * 20
    moves.each do |pair|
      puts pair[0][0..8].ljust(10) + pair[1].ljust(10)
    end
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      print "\nWhat's your name?  "
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts
      print "Please choose rock, paper, scissors, lizard or spock:  "
      choice = gets.chomp.capitalize
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Object.const_get(choice).new
    RPSGame.add_to_history([name, move.to_s])
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'C3PO', 'Hal', 'Chappie', 'Number 5'].sample
  end

  def choose
    self.move = Object.const_get(Move::VALUES.sample).new
    RPSGame.add_to_history([name, move.to_s])
  end
end

RPSGame.new.play
RPSGame.history
