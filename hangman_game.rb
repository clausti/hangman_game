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



class HumanPlayer

  def guess(display_string)
    puts "What's your guess?"
    guess = gets.chomp.downcase
  end

  def choose
    puts "Hey human, choose a word of more than 3 letters.\nThen tell me its length:"
    length = 0
    until length > 3
      length = gets.chomp.to_i
    end
    length
  end

  def positions(letter)
    positions = []
    puts "Is the letter '#{letter}' in your word? (y/n)"
    letter_present = gets.chomp.downcase
    return positions if letter_present == "n"
    puts "What is the first position the letter '#{letter}' is in? (count in from 0)"
    positions << gets.chomp.to_i
    positions += more_positions
  end

  def more_positions
    puts "Any more positions? (y/n)"
    any_more = gets.chomp.downcase
    if any_more == "n"
      return []
    else
      positions = []
      while true
        puts "What's the next position? (Enter 'n' if none)"
        any_more = gets.chomp
        if any_more == 'n'
          break
        else
          positions << any_more.to_i
        end
      end
      positions
    end
  end

  def tell_secret
    puts "What was your secret word?"
    gets.chomp
  end

end



class ComputerPlayer

  def initialize
    @letters_guessed = []

    get_dictionary
    get_alphabet
    @abundance_threshold = 0.90
  end

  def get_dictionary
    #good
    @dictionary = File.readlines("dictionary.txt")
    @dictionary.map!{|word| word.chomp}
    @dictionary.delete_if { |word| word.split('').include?("-") }
  end

  def get_alphabet
    @alphabet = ("a".."z").to_a
  end

  def choose
    @secret_word = ""
    until @secret_word.length > 3
      @secret_word = @dictionary.sample
    end
    @secret_word.length
  end

  def positions(letter)
    secret_letters = @secret_word.split('')
    positions = find_all_index(secret_letters, letter)
  end

  def guess(display_string)
    @dictionary.select!{|word| word.length == display_string.length}
    @dictionary.delete_if{|word| conflict?(display_string, word)}

    letter_counts = count_letters #This is a hash of letter counts
    high_count_letters = top_of_hash(letter_counts)
    guess = high_count_letters.sample

    @letters_guessed << guess
    raise "bad hash" if guess == nil
    guess
  end

  def find_all_index(array, target)
    match_positions = []
    array.each_index do |index|
      match_positions << index if array[index] == target
    end
    match_positions
  end

  def conflict?(display_string, test_word)
    display_chars = display_string.split('')
    display_chars.each_with_index do |char, index|
      next if char == "_"
      return true if test_word[index] != char
    end
    false
  end

  def count_letters
    letter_count = Hash.new(0)

    @dictionary.each do |word|
      word.each_char do |char|
        letter_count[char] +=1
      end
    end
    letter_count
  end

  def top_of_hash(hash)
    max_value = max_of_hash(hash)
    lower_bound = (max_value * @abundance_threshold)
    good_letters = hash.select do |letter, count|
      count >= lower_bound && !(@letters_guessed.include?(letter))
    end
    good_letters.keys #returns an array
  end

  def max_of_hash(hash)
    hash.values.max
  end

  def tell_secret
    @secret_word
  end

end

if __FILE__ == $PROGRAM_NAME
  ourgame = HangmanGame.new
  ourgame.play
end
