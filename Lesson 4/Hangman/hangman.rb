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
      puts "What is your name?"
      answer = gets.chomp
      break if answer.strip != ''
      puts "Please enter a name"
    end
    answer
  end
  
  def choice
    answer = ''
    loop do
      puts "1) Enter a letter"
      puts "2) Guess word"
      print "=> "
      answer = gets.chomp.to_i
      break if [1, 2].include?(answer)
    end
    case answer
    when 1 then self.pick_letter
    when 2 then self.pick_word
    end
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

  def bad_guess
    self.number_of_guesses += 1
    puts  "\nThere aren't any #{self.letter}'s in the word!"
    puts "\n<Press any key to continue>"
    gets
  end
end

class Board
  attr_accessor :tiles
  
  def initialize(computer)
    @tiles = ('_' * computer.word.length).chars
  end

  def show(human)
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
    else
      human.bad_guess
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
    puts "HANGMAN!  Try to guess the word before you run out of guesses!"
  end
  
  def goodbye
    puts "MAN HUNG!!!"
    puts "Thank you for playing HANGMAN"
  end
  
  def letter_match?
    computer.word.include?(player.letter)
  end
      
  def word_match?
    computer.word == player.guess
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
      human.pick_letter
      board.update(computer, human)
      clearscreen
      board.show(human)
      human.pick_word
      break if human.guess == computer.word || human.number_of_guesses == MAX
    end
    if human.guess == computer.word then human_wins
    else computer_wins
    end
  puts "The word was: #{computer.word}"
  goodbye
  end
end

HangManGame.new.play