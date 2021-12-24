Chunk = Struct.new(:open, :close)#, :subchunks)
Result = Struct.new(:chunks, :open_chunks, :invalid_char)
CHUNK_TOKEN_PAIRS = {
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
}
SYNTAX_ERROR_TOKEN_SCORES = {
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
}
AUTOCOMPLETE_TOKEN_SCORES = {
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
}

def parse_navigation_subsystem(file_name)
    navigation_subsystem = []
    File.readlines(File.join(File.dirname(__FILE__), file_name)).each { |file_line|
        navigation_subsystem.push(file_line.chars.select { |c| !c.strip.empty? })
    }
    return navigation_subsystem
end

def find_chunks(line)
    chunks = []
    open_chunks = []
    line.each { |token|
        open_chunk = open_chunks.last
        if !open_chunk.nil? && token == CHUNK_TOKEN_PAIRS[open_chunk]
            opening = open_chunks.pop
            closing = token
            chunks.push(Chunk.new(opening, closing))
        else
            if !open_chunk.nil? && !CHUNK_TOKEN_PAIRS.keys.include?(open_chunk)
                return Result.new(chunks, open_chunks, open_chunk) unless open_chunk.nil?
            else
                open_chunks.push(token)
            end
        end
    }
    return Result.new(chunks, open_chunks, nil)
end

def syntax_error_high_score(navigation_subsystem)
    high_score = 0
    navigation_subsystem.each { |line|
        result = find_chunks(line)
        high_score += SYNTAX_ERROR_TOKEN_SCORES[result.invalid_char] if !result.invalid_char.nil?
    }
    return high_score
end

def autocomplete_high_score(navigation_subsystem)
    incomplete_line_chunks = navigation_subsystem.map { |line|
        result = find_chunks(line)
        if result.invalid_char.nil? && !result.open_chunks.empty?
            result.open_chunks
        else
            nil
        end 
    }.compact

    autocompleted = incomplete_line_chunks.map { |open_chunks|
        autocomplete = open_chunks.map { |open_chunk|
            CHUNK_TOKEN_PAIRS[open_chunk]
        }
        autocomplete
    }

    scores = autocompleted.map { |autocomplete|
        autocomplete.reverse.inject(0) { |current, next_token|
            next_score = 5 * current + AUTOCOMPLETE_TOKEN_SCORES[next_token]
            next_score
        }
    }.sort.reverse

    middle_index = scores.length / 2 # odd numbers round down with integer division
    return scores[middle_index]
end

navigation_subsystem = parse_navigation_subsystem("navigation-subsystem.txt")

# - Part 1

syntax_error_high_score = syntax_error_high_score(navigation_subsystem)
puts "Syntax error high score: #{syntax_error_high_score}"

# - Part 2

autocomplete_high_score = autocomplete_high_score(navigation_subsystem)
puts "Autocomplete high score: #{autocomplete_high_score}"
