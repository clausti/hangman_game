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