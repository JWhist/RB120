module Messages
  MAX_SCORE = 10

  def splash_message(text, duration)
    system('clear') || system('cls')
    top = "+-#{'-' * text.length}-+"
    empty = "| #{' ' * text.length} |"
    mid = "| #{text} |"
    puts top
    puts empty
    puts mid
    puts empty
    puts top
    sleep(duration)
  end

  def money_message
    "How much money can you make before you reach #{MAX_SCORE} wins???"
  end

  def welcome
    splash_message('WELCOME TO TWENTY-ONE!', 2)
    splash_message("First to #{MAX_SCORE} wins is the Grand Winner!", 2)
    splash_message("Don't go broke or you lose!", 2)
    splash_message(money_message, 2)
    splash_message("Blackjack plays 3:2!", 2)
  end

  def goodbye
    puts "Goodbye!"
  end

  def hit_or_stay_prompt
    player.show_hand
    puts "Cash:   Wager: $#{player.wager}  Total Cash:    #{player.show_cash}"
    puts
    puts "You:    Wins:  #{player.wins} Current Hand:    #{player.hand_score}"
    puts '---------------------------------------------'
    puts "Dealer: Wins:  #{dealer.wins}"
    dealer.hand[0].show
    puts "\nHit or Stay?"
    puts "1) Hit"
    puts "2) Stay"
  end

  def prompt_for_wager
    answer = ''
    loop do
      puts "Total cash: #{player.show_cash}"
      print "How much do you want to wager?  "
      answer = gets.chomp.to_f
      break if answer > 0 && answer <= player.cash
      puts "You must wager between $1 and $#{player.cash}."
    end
    player.wager = answer.round(2)
  end

  def score_line
    puts "Cash:   Wager: $#{player.wager}  Total Cash:    #{player.show_cash}"
    puts
    puts "You:    Wins:  #{player.wins} Current Hand:    #{player.hand_score}"
    puts '---------------------------------------------'
    puts "Dealer: Wins:  #{dealer.wins} Current Hand:    #{dealer.hand_score}"
  end

  def blackjack_win_message
    puts "\n****BLACKJACK! YOU WIN!****"
  end

  def blackjack_lose_message
    puts "\n****DEALER HAS BLACKJACK! YOU LOSE!****"
  end

  def display_result_message
    case winner
    when 'Dealer'
      puts "**DEALER WINS!  YOU LOSE! **"
    when 'Player'
      puts "**YOU WIN!**"
    when 'Push'
      puts "**PUSH**"
    end
  end

  def display_grand_winner
    if player.wins == Messages::MAX_SCORE
      splash_message("You are first to #{MAX_SCORE} wins - congrats!", 3)
    elsif dealer.wins == Messages::MAX_SCORE
      splash_message("Dealer has #{MAX_SCORE} wins - you lose!", 3)
    else
      splash_message("You are broke!  You lose!", 3)
    end
  end

  def display_profits
    splash_message("You made $#{format('%.2f', player.cash - 1000.00)}!!", 3)
  end
end

module Scoreable
  CARD_VALUES = {
    2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8,
    9 => 9, 10 => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 11
  }

  def hand_score
    hand_value = hand.inject(0) { |sum, card| sum + CARD_VALUES[card.value] }
    number_of_aces = hand.select { |card| card.value == 'A' }.count
    while hand_value > 21
      break unless number_of_aces > 0
      hand_value -= 10
      number_of_aces -= 1
    end
    hand_value
  end

  def blackjack?
    hand_score == 21
  end

  def busted?
    hand_score > 21
  end

  def reset_wins
    self.wins = 0
  end
end

class Player
  include Scoreable
  attr_accessor :hand, :wins, :cash, :wager

  def initialize
    @hand = []
    @wins = 0
    @cash = 1000.00
    @wager = 0
  end

  def hit(deck)
    deck.deal_a_card(self)
  end

  def show_hand
    hand.each(&:show)
  end

  def show_cash
    "$#{format('%.2f', @cash)}"
  end

  def broke?
    cash <= 0
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = reset
  end

  def reset
    deck = []
    ["\u2661", "\u2667", "\u2664", "\u2662"].each do |suit|
      2.upto(10).each do |value|
        deck << Card.new(suit, value)
      end
      ["J", "Q", "K", "A"].each do |value|
        deck << Card.new(suit, value)
      end
    end
    @cards = deck
  end

  def deal_a_card(player)
    player.hand << @cards.pop
  end

  def shuffle!
    @cards.shuffle!
  end
end

class Card
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def show
    puts "+---------+"
    puts "|#{format('%-2s', suit)}       |"
    puts "|         |"
    puts "|   #{format('%2s', value)}    |"
    puts "|         |"
    puts "|      #{format('%2s', suit)} |"
    puts "+---------+"
  end

  def to_s
    [@suit, @value]
  end
end

class TwentyOneGame
  include Messages

  attr_accessor :player, :dealer, :winner
  attr_reader :deck

  def initialize
    @player = Player.new
    @dealer = Player.new
    @deck = Deck.new
    @winner = ''
    deck.shuffle!
    welcome
  end

  def reset
    player.hand = []
    dealer.hand = []
    winner = ''
    player.wager = 0
    @deck = Deck.new
    deck.shuffle!
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def first_deal
    clear_screen
    2.times do
      player.hit(deck)
      dealer.hit(deck)
    end
  end

  def show_table
    player.show_hand
    score_line
    dealer.show_hand
  end

  def players_move!
    input = ''
    loop do
      clear_screen
      hit_or_stay_prompt
      return if player.busted?
      input = gets.chomp
      case input
      when '1'
        player.hit(deck)
        puts "Dealing a card..."
        sleep(0.75)
      when '2'then break
      else
        puts "Please choose 1 or 2"
        sleep(1)
      end
    end
  end

  def dealers_move!
    loop do
      clear_screen
      show_table
      sleep(0.75)
      dealer.hand_score < 17 ? dealer.hit(deck) : break
    end
  end

  def dealer_won?
    player.busted? || dealer.hand_score > player.hand_score && !dealer.busted?
  end

  def player_won?
    dealer.busted? || player.hand_score > dealer.hand_score && !player.busted?
  end

  def tie
    !dealer_won? && !player_won?
  end

  def determine_winner
    self.winner = 'Dealer' if dealer_won?
    self.winner = 'Player' if player_won?
    self.winner = 'Push' if tie
  end

  def update_wins
    player.wins += 1 if winner == 'Player'
    dealer.wins += 1 if winner == 'Dealer'
  end

  def update_cash_blackjack
    player.cash += (1.5 * player.wager) if winner == 'Player'
    player.cash -= player.wager if winner == 'Dealer'
  end

  def update_cash
    player.cash += player.wager if winner == 'Player'
    player.cash -= player.wager if winner == 'Dealer'
  end

  def max_score_reached?
    player.wins >= Messages::MAX_SCORE || dealer.wins >= Messages::MAX_SCORE
  end

  def reset_wins
    player.reset_wins
    dealer.reset_wins
    player.cash = 1000.00
  end

  def play_again?
    print "Press any key to PLAY AGAIN or 'Q' to quit --> "
    gets.chomp.downcase != 'q'
  end

  def blackjack_situation?
    if player.blackjack?
      clear_screen
      determine_winner
      update_wins
      update_cash_blackjack
      show_table
      blackjack_win_message
      any_key
      reset
      return true
    elsif dealer.blackjack?
      clear_screen
      determine_winner
      update_wins
      update_cash_blackjack
      show_table
      blackjack_lose_message
      any_key
      reset
      return true
    end
    false
  end

  def finalize
    clear_screen
    determine_winner
    update_wins
    update_cash
    show_table
    display_result_message
    any_key
    reset
  end

  def any_key
    puts "Press any key to continue"
    gets
  end

  def game_over_quit?
    if max_score_reached? || player.broke?
      display_grand_winner
      display_profits
      reset_wins
      return !play_again?
    end
    false
  end

  def play
    loop do
      clear_screen
      prompt_for_wager
      first_deal
      if blackjack_situation?
        game_over_quit? ? break : next
      end
      players_move!
      if player.busted?
        finalize
        game_over_quit? ? break : next
      end
      dealers_move!
      if dealer.busted?
        finalize
        game_over_quit? ? break : next
      end
      finalize
      game_over_quit? ? break : next
    end
    goodbye
  end
end

TwentyOneGame.new.play
