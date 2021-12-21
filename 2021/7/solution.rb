
def parse_crab_positions(file_name)
    crab_positions = []
    crab_positions_delimiter = ","
    File.readlines(File.join(File.dirname(__FILE__), file_name)).each { |file_line|
        # In case they're ever on multiple lines?
        current_crab_positions = file_line.split(crab_positions_delimiter).map { |crab_position| crab_position.to_i }
        crab_positions.push(*current_crab_positions)
    }
    return crab_positions
end

def calculate_fuel_for_best_position(positions, &fuel_consumption)
    max_position = positions.max
    min_position = positions.min

    total_fuel_used = {}
    (min_position..max_position).each { |proposed_position|
        total_fuel = 0
        positions.each { |position|
            total_fuel += fuel_consumption.call(proposed_position, position)
        }
        total_fuel_used[proposed_position.to_s] = total_fuel
    }
    least_fuel_used = total_fuel_used.values.first
    best_position = min_position
    total_fuel_used.each { |k, v|
        if v < least_fuel_used
            best_position = k.to_i 
            least_fuel_used = v
        end
    }
    return least_fuel_used
end

crab_positions = parse_crab_positions("crab-positions.txt")

# - Part 1

least_fuel_used = calculate_fuel_for_best_position(crab_positions) { |from, to|
    (from - to).abs
}
puts "Least fuel used: #{least_fuel_used}"

# - Part 2

least_fuel_used = calculate_fuel_for_best_position(crab_positions) { |from, to|
    n = (from - to).abs
    sum_up_to_n = n * (n + 1) / 2
    sum_up_to_n
}
puts "Least fuel used: #{least_fuel_used}"
