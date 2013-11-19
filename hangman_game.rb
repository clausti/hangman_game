require './computer_player.rb'
require './human_player.rb'


class HangmanGame

  NUM_TURNS = 6

  def initialize
    @used_letters = []
  end

  def populate_players
    puts "How many human players?"
    humans = gets.chomp.to_i
    humans.times {@players << HumanPlayer.new}
    (2-humans).times {@players << ComputerPlayer.new}
    assign_roles(humans)
  end

  def assign_roles(humans)
    if humans == 0
      @gamemaster = @players[0]
      @guesser = @players[1]
    else
      puts "Who is choosing the word? (If one human, human is Player 1.) \nPlayer number:"
      gamemaster = gets.chomp.to_i
      @gamemaster = @players[gamemaster - 1]
      @guesser = @players[2 - gamemaster]
    end
  end

  def set_secret_word
    length = @gamemaster.choose
    @display_string = "_" * length
  end

  def render
    print "Secret word: "
    print @display_string
    print "\n"
  end

  def ask_guess
    valid_guess = false
    until valid_guess
      guess = @guesser.guess(@display_string)
      valid_guess = valid_guess?(guess)
      puts "Invalid. Guess?" unless valid_guess
    end
    former_display = @display_string.dup
    update_dispay_string(guess)
    @turns_left -= 1 if former_display == @display_string
    @used_letters << guess
  end

  def valid_guess?(guess)
    return false if guess.length != 1
    return false unless guess =~ /[a-z]/
    return false if @used_letters.include?(guess)
    true
  end

  def update_dispay_string(letter)
    positions = @gamemaster.positions(letter)
    positions.each do |position|
      @display_string[position] = letter
    end
  end

  def player_winning?
    !(@display_string.include?("_"))
  end

  def play
    @used_letters = []
    @players = []
    populate_players
    set_secret_word
    @turns_left = NUM_TURNS
    render
    puts
    until @turns_left == 0
      ask_guess
      render
      if player_winning?
        puts "You win!"
        return
      end
      puts "Guesses remaning: #{@turns_left}\n\n"
    end
    puts "Hanged! The secret word was #{@gamemaster.tell_secret}"
  end

end


if __FILE__ == $PROGRAM_NAME
  ourgame = HangmanGame.new
  ourgame.play
end
