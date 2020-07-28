class Player
  @@alphabet = ('A'..'Z').to_a
  attr_accessor :word, :name
  
  def initialize(name)
    @name = name
  end

  def self.alphabet
    @@alphabet.join(' ')
  end
end

class Computer < Player
  def initialize
    super("Hangman")
    @dictionary = File.readlines('dict.txt').map(&:chomp)
    choose_word
  end
  
  def choose_word
    self.word = @dictionary.sample
  end
end

class Human < Player
  attr_accessor :guess, :name, :letter, :number_of_guesses
  
  def initialize
    @name = name_yourself
    @number_of_guesses = 0
  end

  def name_yourself
    answer = ''
    loop do
      print "What is your name?  "
      answer = gets.chomp
      break if answer.strip != ''
      puts "Please enter a name"
    end
    answer
  end
  
  def choice
    answer = ''
    loop do
      puts "\n1) Enter a letter"
      puts "2) Guess the word"
      print "\nPlease choose 1 or 2: "
      answer = gets.chomp.to_i
      break if [1, 2].include?(answer)
    end
    case answer
    when 1 then self.pick_letter
    when 2 then self.pick_word
    end
    answer
  end

  def pick_letter
    answer = ''
    loop do
      print "\nPick a LETTER: "
      answer = gets.chomp.upcase
      if answer.length > 1
        puts "Please enter a single letter character."
        next
      end
      break if @@alphabet.include?(answer)
      puts "Letter has already been picked.  Pick again."
    end
    @@alphabet.delete(answer)
    self.letter = answer
  end
      
  def pick_word
    print "\nEnter a WORD: "
    answer = nil
    loop do
      answer = gets.chomp.upcase
      break if !answer.empty?
      puts "please enter a valid option" 
    end
    self.guess = answer
  end

  def bad_letter_guess
    self.number_of_guesses += 1
    puts  "\nThere aren't any #{self.letter}'s in the word!"
    puts "\n<Press any key to continue>"
    gets
  end

  def bad_word_guess
    self.number_of_guesses += 1
    puts "\n #{self.guess} is not the word!"
    puts "\n<Press any key to continue>"
    gets
  end
end

class Board
  require 'yaml'
  GALLOWS = YAML.load_file('gallows.yml')
  attr_accessor :tiles
  
  def initialize(computer)
    @tiles = ('_' * computer.word.length).chars
  end

  def show_gallows(human)
    case human.number_of_guesses
    when 0 then puts GALLOWS["hang0"]
    when 1 then puts GALLOWS["hang1"]
    when 2 then puts GALLOWS["hang2"]
    when 3 then puts GALLOWS["hang3"]
    when 4 then puts GALLOWS["hang4"]
    when 5 then puts GALLOWS["hang5"]
    end
  end

  def show(human)
    show_gallows(human)
    puts "\nAvailable letters:"
    puts "\n#{Player.alphabet}"
    puts "\n#{tiles.join(' ')}"
    puts "Number of misses:  #{human.number_of_guesses}/#{HangManGame::MAX}"
  end

  def update(computer, human)
    if computer.word.include?(human.letter)
      computer.word.chars.each_with_index do |char, idx| 
        char == human.letter ? self.tiles[idx] = char : next
      end
    end
  end
end
      
      
class HangManGame
  MAX = 6
  attr_accessor :board, :human, :computer
  def initialize
    welcome
    @computer = Computer.new
    @human = Human.new
    @board = Board.new(@computer)
  end

  def welcome
    clearscreen
    puts "HANGMAN!  Try to guess the word before you run out of guesses!"
  end
  
  def goodbye
    puts "MAN HUNG!!!"
    puts "Thank you for playing HANGMAN"
  end
  
  def letter_match?
    computer.word.include?(human.letter)
  end
      
  def word_match?
    computer.word == human.guess
  end

  def max_score
    human.number_of_guesses == MAX
  end

  def computer_wins
    puts "Hangman wins, #{human.name} loses!"
  end

  def human_wins
    puts "#{human.name} saved the man! #{human.name} wins!"
  end

  def clearscreen
    system('clear') || system('cls')
  end

  def play
    loop do
      clearscreen
      board.show(human)
      men = human.choice
      board.update(computer, human)
      human.bad_letter_guess if men == 1 && !letter_match?
      human.bad_word_guess if men == 2 && human.guess != computer.word
      break if word_match? || max_score
    end
  word_match? ? human_wins : computer_wins
  puts "The word was: #{computer.word}"
  goodbye
  end
end

HangManGame.new.play