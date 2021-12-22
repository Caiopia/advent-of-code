
SEGMENTS_PER_DIGIT = {
    "0": "abcefg",
    "1": "cf",
    "2": "acdeg",
    "3": "acdfg",
    "4": "bcdf",
    "5": "abdfg",
    "6": "abdefg",
    "7": "acf",
    "8": "abcdefg",
    "9": "abcdfg"
}

def parse_signals(file_name)
    signal_output_delimiter = "|"
    digit_delimiter = " "
    entries = []
    File.readlines(File.join(File.dirname(__FILE__), file_name)).each { |file_line|
        tmp_entry = file_line.split(signal_output_delimiter)
        entry = [tmp_entry[0].split(digit_delimiter), tmp_entry[1].split(digit_delimiter)]
        entries.push(entry)
    }
    return entries
end

def output_mappings_for_entry(entry)
    possible_mappings = {}
    random_signals = entry[0]
    output_values = entry[1]
    random_signals.each { |signal|
        SEGMENTS_PER_DIGIT.each { |k, v| 
            if v.length == signal.length
                possible_mappings[k.to_s] = [] if possible_mappings[k.to_s].nil?
                possible_mappings[k.to_s].push(signal.chars.sort.join) # sort alphabetically to make it easier to compare later.
            end
        }
    }

    # one

    one = possible_mappings["1"]
    raise "Not exactly 1 mapping for one: #{one}" if one.length != 1

    # four

    four = possible_mappings["4"]
    raise "Not exactly 1 mapping for four: #{four}" if four.length != 1

    # seven

    seven = possible_mappings["7"]
    raise "Not exactly 1 mapping for seven: #{seven}" if seven.length != 1

    # eight

    eight = possible_mappings["8"]
    raise "Not exactly 1 mapping for eight: #{eight}" if eight.length != 1

    # three

    three = possible_mappings["3"].select! { |mapping|
        (mapping.chars - one.first.chars).length == 3
    }
    raise "Not exactly 1 mapping for three: #{three}" if three.length != 1

    # five

    five = possible_mappings["5"].select! { |mapping|
        mapping.chars.length == 5 && (mapping.chars - four.first.chars).length == 2 && mapping != three.first
    }
    raise "Not exactly 1 mapping for five: #{five}" if five.length != 1

    # nine

    nine = possible_mappings["9"].select! { |mapping|
        mapping.chars.length == 6 && (mapping.chars - four.first.chars).length == 2
    }
    raise "Not exactly 1 mapping for nine: #{nine}" if nine.length != 1

    # six

    six = possible_mappings["6"].select! { |mapping|
        (mapping.chars - five.first.chars).length == 1 && mapping != nine.first
    }
    raise "Not exactly 1 mapping for six: #{six}" if six.length != 1

    # zero

    zero = possible_mappings["0"].select! { |mapping|
        mapping != nine.first && mapping != six.first
    }
    raise "Not exactly 1 mapping for zero: #{zero}" if zero.length != 1

    # two

    two = possible_mappings["2"].select! { |mapping|
        mapping != three.first && mapping != five.first
    }
    raise "Not exactly 1 mapping for two: #{two}" if two.length != 1

    ## - Analyze output

    output = output_values.map { |output|
        match = nil
        possible_mappings.select { |k, v|
            match = k if output.chars.sort == v.first.chars
        }
        match
    }

    return output
end

# - Part 1

def number_of_occurrences(entries, digits)
    count = 0
    entries.each { |entry|
        output = output_mappings_for_entry(entry)
        digits.each { |digit|
            count += output.select { |o| o == digit }.length
        }
    }
    return count
end

# - Part 2

def sum_of_outputs(entries)
    entries.map { |entry|
        output = output_mappings_for_entry(entry)
        # puts output
        output.join.to_i
    }.sum
end

entries = parse_signals("signal-patterns.txt")
values = ["1", "4", "7", "8"]
count = number_of_occurrences(entries, values)
puts "Number of #{values}: #{count}"

sum_of_outputs = sum_of_outputs(entries)
puts "Sum of outputs: #{sum_of_outputs}"

