BingoNumber = Struct.new(:value, :called)
BingoGame = Struct.new(:called_numbers, :boards)

class BingoBoard

    def initialize(board)
        @board = board
        @called_numbers = []
    end

    # - Win conditions

    def has_horizontal_win
        for row in @board
            has_win = true
            for bingo_number in row
                has_win = has_win && bingo_number.called
            end
            return has_win if has_win
        end
        return false
    end

    def has_vertical_win
        has_win = true
        x = 0
        while x < @board.first.length # Assume all boards rows are the same length
            y = 0
            while y < @board.length
                has_win = has_win && @board[y][x].called
                y += 1
            end
            return has_win if has_win == true
            x += 1
            has_win = true
        end
        return false
    end

    def has_win
        return has_horizontal_win || has_vertical_win
    end

    # - Numbers

    def call_number(number)
        for bingo_line in @board
            bingo_line.map! { |bingo_number|
                if bingo_number.value == number
                    bingo_number.called = true
                    @called_numbers << bingo_number
                end
                bingo_number
            }
        end
    end

    def current_numbers(called)
        numbers = []
        for row in @board
            for bingo_number in row
                numbers << bingo_number if bingo_number.called == called
            end
        end
        return numbers
    end

    # - Printing

    def print_board
        string = ""
        for board_line in @board
            for bingo_number in board_line
                number = bingo_number.value
                string += "#{number} "
            end
            string += "\n"
        end
        return string
    end

    def print_called
        string = ""
        for board_line in @board
            for bingo_number in board_line
                called = bingo_number.called
                number = bingo_number.value
                string += "(#{number} #{called}) | "
            end
            string += "\n"
        end
        return string
    end

    def print_score
        raise "Bingo board needs to win to have a score" if has_win == false
        
        uncalled_numbers = current_numbers(false).map { |number| number.value.to_i }
        uncalled_numbers_sum = uncalled_numbers.reduce(0) { |sum, current| sum + current }

        puts "Uncalled numbers: #{uncalled_numbers}"
        puts "Uncalled numbers sum: #{uncalled_numbers_sum}"
        puts "Score: #{uncalled_numbers_sum * @called_numbers.last.value.to_i}"
    end
end

# - Parsing

def parse_game(file_name)
    called_numbers = []
    bingo_boards = []
    current_board = []

    lines = File.readlines(File.join(File.dirname(__FILE__), file_name))
    lines.each_with_index do |line, line_num|
        stripped_line = line.strip()

        if line_num == 0 
            called_numbers = stripped_line.split(",")
            next
        end

        if stripped_line == ""
            next if current_board.empty?
            
            bingo_boards.append(BingoBoard.new(current_board))
            current_board = []
        elsif line_num == lines.length - 1
            board_line = parse_board_line(stripped_line)
            current_board.append(board_line)

            bingo_boards.append(BingoBoard.new(current_board))
            current_board = []
        else
            board_line = parse_board_line(stripped_line)
            current_board.append(board_line)
        end
    end

    raise "No called numbers found" if called_numbers.empty?
    raise "No bingo boards found" if bingo_boards.empty?
    # Can add more validations here like board dimensions?

    bingo_game = BingoGame.new
    bingo_game.called_numbers = called_numbers
    bingo_game.boards = bingo_boards

    return bingo_game
end

def parse_board_line(board_line)
    bingo_line = board_line.split(" ").map { |number|
        bingo_number = BingoNumber.new
        bingo_number.value = number
        bingo_number.called = false
        bingo_number
    }
end

# - Play

def play(bingo_game)
    previous_winning_boards = []
    bingo_game.called_numbers.each { |called_number|
        puts "Number called: #{called_number}\n"
        winning_boards = bingo_game.boards.map { |board|
            board.call_number(called_number)
            board.has_win ? board : nil
        }

        has_winner = !winning_boards.compact.empty?
        previous_has_winner = !previous_winning_boards.compact.empty?
        has_loser = !winning_boards.include?(nil)
        
        if has_winner && !previous_has_winner
            puts "\nFirst winning number: #{called_number}"
            puts "First winning boards:" # Make sure you yell "Bingo" fast if there are multiple winners...
            for winning_board in winning_boards.compact
                puts winning_board.print_called
                puts winning_board.print_score
            end
        end

        if has_loser
            puts "\nLast winning number: #{called_number}"
            puts "Last winning boards:"
            for winning_board in (winning_boards - previous_winning_boards).compact # in case there are multiple boards that win last    
                puts winning_board.print_called
                puts winning_board.print_score
            end
            break # end when the last card wins
        end

        previous_winning_boards = winning_boards
    }
end

bingo_game = parse_game("bingo-game.txt")
play(bingo_game)