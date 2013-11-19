class ComputerPlayer

  def initialize
    @letters_guessed = []

    get_dictionary
    get_alphabet
    @abundance_threshold = 0.90
  end

  def get_dictionary
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
    guess = high_count_letters.sample || letter_counts.keys.sample

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