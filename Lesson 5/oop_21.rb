module Messages
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
    score = TwentyOneGame::MAX_SCORE
    "How much money can you make before you reach #{score} wins???"
  end

  def welcome
    score = TwentyOneGame::MAX_SCORE
    splash_message('WELCOME TO TWENTY-ONE!', 2)
    splash_message("First to #{score} wins is the Grand Winner!", 2)
    splash_message("Don't go broke or you lose!", 2)
    splash_message(money_message, 2)
    splash_message("Blackjack plays 3:2 !!", 2)
  end

  def hit_or_stay_prompt
    one_card_score_line
    puts dealer.hand[0].show.join("\n")
    puts "\nHit or Stay?"
    puts "1) Hit\n2) Stay"
  end

  def one_or_two_please
    puts "Please choose 1 or 2"
    sleep(1)
  end

  def prompt_for_wager
    answer = ''
    loop do
      puts "\n\nTotal cash: #{player.show_cash}"
      print "How much do you want to wager?  "
      answer = gets.chomp.to_f
      break if answer > 0 && answer <= player.cash
      puts "You must wager between $1 and $#{format('%.2f', player.cash)}."
    end
    player.wager = answer.round(2)
  end

  def wager_line
    pscore = player.hand_score
    wager = format('%.2f', player.wager)
    puts "Cash:   Wager: $#{wager}  Total Cash:    #{player.show_cash}"
    puts "Wins:  Player:  #{player.wins}          Dealer:     #{dealer.wins}"
    puts "\nYour Cards:          Current Hand:     #{pscore}"
    player.show_hand
    puts '---------------------------------------------'
  end

  def score_line
    wager_line
    puts "Dealer Cards:          Current Hand:     #{dealer.hand_score}"
  end

  def one_card_score_line
    wager_line
    puts "Dealer Cards:"
  end

  def blackjack_win_message
    puts "\n****BLACKJACK! YOU WIN!****"
  end

  def blackjack_lose_message
    puts "\n****DEALER HAS BLACKJACK! YOU LOSE!****"
  end

  def win_message
    puts "**YOU WIN!**"
  end

  def lose_message
    puts "**DEALER WINS!  YOU LOSE! **"
  end

  def display_result_message
    case winner
    when 'Dealer'
      dealer.blackjack? ? blackjack_lose_message : lose_message
    when 'Player'
      player.blackjack? ? blackjack_win_message : win_message
    when 'Push'
      puts "**PUSH**"
    end
  end

  def display_grand_winner
    score = TwentyOneGame::MAX_SCORE
    if player.wins == score
      splash_message("You are first to #{score} wins - congrats!", 3)
    elsif dealer.wins == score
      splash_message("Dealer has #{score} wins - you lose!", 3)
    else
      splash_message("You are broke!  You lose!", 3)
    end
  end

  def display_profits
    if profits >= 0
      splash_message("You made $#{format('%.2f', profits)}!!", 3)
    else
      splash_message("You lost $#{format('%.2f', -profits)}!!", 3)
    end
  end
end

module Scoreable
  WIN_PIVOT = 21
  CARD_VALUES = {
    2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8,
    9 => 9, 10 => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 11
  }

  def hand_score
    hand_value = hand.inject(0) { |sum, card| sum + CARD_VALUES[card.value] }
    number_of_aces = hand.select { |card| card.value == 'A' }.count
    while hand_value > WIN_PIVOT
      break unless number_of_aces > 0
      hand_value -= 10
      number_of_aces -= 1
    end
    hand_value
  end

  def blackjack?
    hand_score == WIN_PIVOT && hand.size == 2
  end

  def busted?
    hand_score > WIN_PIVOT
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
    hand_display = Array.new(7) { [] }
    hand.each do |card|
      card.show.each_with_index do |row, idx|
        hand_display[idx] << row
      end
    end
    puts hand_display.map(&:join).join("\n")
  end

  def show_cash
    "$#{format('%.2f', @cash)}"
  end

  def broke?
    cash <= 0
  end

  def reset_wins
    self.wins = 0
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
    [
      ["+---------+ "],
      ["|#{format('%-2s', suit)}       | "],
      ["|         | "],
      ["|   #{format('%2s', value)}    | "],
      ["|         | "],
      ["|      #{format('%2s', suit)} | "],
      ["+---------+ "]
    ]
  end

  def to_s
    [@suit, @value]
  end
end

class TwentyOneGame
  HOLD_PIVOT = 17
  MAX_SCORE = 5
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

  def play
    loop do
      play_round
      finalize
      game_over_quit? ? break : next
    end
    goodbye
  end

  private

  def play_round
    prompt_for_wager
    first_deal
    return if blackjack_situation?
    players_move!
    dealers_move! unless player.busted?
  end

  def reset
    player.hand = []
    dealer.hand = []
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
    score_line
    dealer.show_hand
  end

  def hit_option
    player.hit(deck)
    puts "Dealing a card..."
    sleep(0.75)
  end

  def players_move!
    loop do
      clear_screen
      hit_or_stay_prompt
      return if player.busted?
      input = gets.chomp
      hit_option if input == '1'
      break if      input == '2'
      one_or_two_please if !['1', '2'].include?(input)
    end
  end

  def dealers_move!
    loop do
      clear_screen
      show_table
      sleep(0.75)
      dealer.hand_score < HOLD_PIVOT ? dealer.hit(deck) : break
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

  def update_cash
    if player.blackjack?
      player.cash += player.wager * 1.5
    elsif winner == 'Player'
      player.cash += player.wager
    elsif winner == 'Dealer'
      player.cash -= player.wager
    end
  end

  def max_score_reached?
    score = TwentyOneGame::MAX_SCORE
    player.wins >= score || dealer.wins >= score
  end

  def reset_wins_and_cash
    player.reset_wins
    dealer.reset_wins
    player.cash = 1000.00
  end

  def profits
    format('%.2f', player.cash - 1000.00).to_f
  end

  def play_again?
    print "Press any key to PLAY AGAIN or 'Q' to quit --> "
    gets.chomp.downcase != 'q'
  end

  def blackjack_situation?
    player.blackjack? || dealer.blackjack?
  end

  def finalize
    clear_screen
    determine_winner
    update_wins
    update_cash
    show_table
    display_result_message
    reset
  end

  def game_over_quit?
    if max_score_reached? || player.broke?
      sleep(2)
      display_grand_winner
      display_profits
      reset_wins_and_cash
      return !play_again?
    end
    false
  end

  def goodbye
    puts "Goodbye!"
  end
end

game = TwentyOneGame.new
game.play
