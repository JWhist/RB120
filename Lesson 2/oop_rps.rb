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

class Player
  require 'yaml'
  MESSAGES = YAML.load_file('rps_messages.yml')
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def history
    clearscreen
    moves = move_history
    puts
    puts "PLAYER HISTORY:"
    puts "Player".ljust(10) + "Move".ljust(10) + "W/L".ljust(10)
    puts "-" * 30
    moves.each { |move| print_history_line(move) }
  end

  private

  def clearscreen
    system('clear') || system('cls')
  end

  def move_history
    RPSGame.move_history.each_slice(3)
  end

  def print_history_line(move)
    puts move[0][0][0..8].ljust(10) + move[0][1].ljust(10) + move[2]
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      print(MESSAGES["name"])
      n = gets.chomp
      break unless n.strip.empty?
      puts(MESSAGES["sorry"])
    end
    self.name = n
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

  private

  def choice_menu
    puts(MESSAGES["menu"])
  end

  def print_history_or_invalid(choice)
    history if choice == 6
    RPSGame.history if choice == 7
    puts(MESSAGES["sorry2"]) if ![6, 7].include?(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'C3PO', 'Hal', 'Chappie', 'Number 5'].sample
  end

  def choose
    logic = set_logic
    self.move = Object.const_get(logic).new
    RPSGame.add_to_history([name, move.to_s])
  end

  private

  def set_logic
    logic = { 'R2D2' => r2d2_logic, 'C3PO' => c3po_logic, 'Hal' => hal_logic,
              'Chappie' => chappie_logic, 'Number 5' => number_5_logic }
    logic[name]
  end

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
    when 61..99 then "Spock"
    else
      "Scissors"
    end
  end

  def number_5_logic
    ['Spock', 'Lizard'].sample
  end
end

class RPSGame
  require 'yaml'
  MESSAGES = YAML.load_file('rps_messages.yml')
  MAX_SCORE = 5
  attr_accessor :human, :computer

  @@history = []

  def initialize
    clearscreen
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts(format(MESSAGES["welcome"], score: MAX_SCORE))
  end

  def display_goodbye_message
    puts(format(MESSAGES["bye1"], score: MAX_SCORE)) if human_wins?
    if computer_wins?
      puts(format(MESSAGES["bye2"], cpu: computer.name, score: MAX_SCORE))
    end
    puts(MESSAGES["bye3"])
  end

  def display_choices
    puts(format(MESSAGES["hchoice"], hum: human.name, mov: human.move))
    puts(format(MESSAGES["cchoice"], cpu: computer.name, mov: computer.move))
  end

  def tension
    puts("\n   1..")
    sleep(0.4)
    puts('   2..')
    sleep(0.4)
    puts('   3...')
    sleep(0.4)
    puts '   SHOOT!'
  end

  def human_wins?
    human.move > computer.move
  end

  def computer_wins?
    computer.move > human.move
  end

  def tie?
    !human_wins? && !computer_wins?
  end

  def update_scores
    human.score += 1 if human_wins?
    computer.score += 1 if computer_wins?
  end

  def save_result
    @@history << "Win" if human_wins?
    @@history << "Loss" if computer_wins?
    @@history << "Tie" if tie?
  end

  def max_score_reached?
    human.score == MAX_SCORE || computer.score == MAX_SCORE
  end

  def display_winner
    puts(format(MESSAGES["hwin"], person: human.name)) if human_wins?
    puts(format(MESSAGES["cwin"], person: computer.name)) if computer_wins?
    puts(MESSAGES["tie"])  if tie?
  end

  def display_scores
    puts "\n#{human.name}: #{human.score}  #{computer.name}: #{computer.score}"
  end

  def play_again?
    answer = ''
    loop do
      print(MESSAGES["again"])
      answer = gets.chomp.upcase
      break if ['Y', 'N'].include?(answer)
      puts(MESSAGES["yorn"])
    end
    answer == 'Y'
  end

  def pause
    puts(MESSAGES["anykey"])
    gets
  end

  def clearscreen
    system('clear') || system('cls')
  end

  def main_loop
    clearscreen
    display_scores
    human.choose
    tension
    computer.choose
    display_choices
    update_scores
    save_result
    display_winner
    pause
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
    clearscreen
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
    def clearscreen
      system('clear') || system('cls')
    end

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

RPSGame.new.play
