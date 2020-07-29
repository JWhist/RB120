class Player
  @@alphabet = ('A'..'Z').to_a
  attr_accessor :word, :name

  def initialize(name)
    @name = name
  end

  def self.alphabet
    @@alphabet.join(' ')
  end

  def self.new_alphabet
    @@alphabet = ('A'..'Z').to_a
  end

  def self.alphabet_delete(letter)
    @@alphabet.delete(letter)
  end
end

class Computer < Player
  attr_accessor :level

  def initialize
    super("Hangman")
    @dictionary = File.readlines('dict.txt').map(&:chomp)
    choose_word
  end

  def select_level(level = nil)
    system('clear') || system('cls')
    puts "What level would you like to play?"
    puts "1) Easy\n2) Medium\n3) Hard\n4) Extreme"
    print "==>  "
    loop do
      level = gets.chomp.to_i
      break if [1, 2, 3, 4].include?(level)
      puts "Invalid choice, please choose 1, 2, 3 or 4."
    end
    @level = level
  end

  def vowel?(word, count)
    vowels = 'AEIOU'
    counter = word.count(vowels)
    counter > count
  end

  def hard_letters?(word, count)
    hard_letters = 'QXYZVWP'
    counter = word.count(hard_letters)
    counter > count
  end

  def easy_criteria(word)
    word.size <= 7 && vowel?(word, 2) && !hard_letters?(word, 0)
  end

  def med_criteria(word)
    (word.size >= 5) && (word.chars.uniq != word.chars) && vowel?(word, 1)
  end

  def hard_criteria(word)
    (word.size >= 5) && (word.chars.uniq == word.chars) && (!vowel?(word, 0))
  end

  def ext_criteria(word)
    (word.size >= 5) && (hard_letters?(word, 2)) && !vowel?(word, 0)
  end

  def word_choice
    case @level
    when 1 then @dictionary.select { |word| easy_criteria(word) }
    when 2 then @dictionary.select { |word| med_criteria(word) }
    when 3 then @dictionary.select { |word| hard_criteria(word) }
    when 4 then @dictionary.select { |word| ext_criteria(word) }
    end
  end

  def choose_word
    select_level
    self.word = word_choice.sample
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

  def menu
    puts "\n1) Enter a letter"
    puts "2) Guess the word"
    print "\nPlease choose 1 or 2: "
  end

  def choice
    answer = ''
    loop do
      menu
      answer = gets.chomp.to_i
      break if [1, 2].include?(answer)
    end
    pick_letter if answer == 1
    pick_word if answer == 2
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
    puts "\nThere aren't any #{letter}'s in the word!"
    puts "\n<Press any key to continue>"
    gets
  end

  def bad_word_guess
    self.number_of_guesses += 1
    puts "\n #{guess} is not the word!"
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

  def reset(computer)
    @tiles = ('_' * computer.word.length).chars
  end

  def show_gallows(human)
    puts GALLOWS["hang" + human.number_of_guesses.to_s]
  end

  def show(human)
    show_gallows(human)
    puts "\nAvailable letters:"
    puts "\n#{Player.alphabet}"
    puts "\n#{tiles.join(' ')}"
    puts "Number of misses:  #{human.number_of_guesses}/#{HangManGame::MAX}"
  end

  def cycle(computer)
    ['R', 'S', 'T', 'L', 'N', 'E'].each do |let|
      computer.word.chars.each_with_index do |char, idx|
        if char == let
          tiles[idx] = char
          Player.alphabet_delete(let)
        else
          Player.alphabet_delete(let)
          next
        end
      end
    end
  end

  def update(computer, human)
    cycle(computer) if computer.level == 1
    return unless computer.word.include?(human.letter)
    computer.word.chars.each_with_index do |char, idx|
      char == human.letter ? tiles[idx] = char : next
    end
  end
end

class HangManGame
  MAX = 6
  attr_accessor :board, :human, :computer

  def initialize
    welcome
    @human = Human.new
    @computer = Computer.new
    @board = Board.new(@computer)
  end

  def welcome
    clearscreen
    puts "HANGMAN!  Try to guess the word before you run out of guesses!"
  end

  def goodbye
    puts "\nThank you for playing HANGMAN"
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

  def bad_guess(men)
    human.bad_letter_guess if men == 1 && !letter_match?
    human.bad_word_guess if men == 2 && human.guess != computer.word
  end

  def main_loop
    clearscreen
    board.cycle(computer) if computer.level == 1
    board.show(human)
    men = human.choice
    board.update(computer, human)
    bad_guess(men)
  end

  def play_again?
    answer = ''
    loop do
      puts "\nWould you like to play again?"
      print "\nY or N:  "
      answer = gets.chomp.upcase
      break if ['Y', 'N'].include?(answer) && answer.length == 1
      puts "Please enter Y or N"
    end
    answer == 'Y'
  end

  def show_winner_and_word
    word_match? ? human_wins : computer_wins
    puts "The word was: #{computer.word}"
  end

  def reset
    human.number_of_guesses = 0
    computer.choose_word
    board.reset(computer)
    Player.new_alphabet
  end

  def play
    loop do
      loop do
        main_loop
        break if word_match? || max_score
      end
      show_winner_and_word
      break unless play_again?
      reset
    end
    goodbye
  end
end

HangManGame.new.play
