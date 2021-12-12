DIRECTIONS = [:forward, :up, :down]

Movement = Struct.new(:direction, :units)
Position = Struct.new(:horizontal, :depth, :aim)

def calculate_position(movements, initial_position)
    final_position = initial_position
    for movement in movements
        case movement.direction
        when :forward
            final_position.horizontal += movement.units
            final_position.depth += final_position.aim * movement.units
        when :up
            final_position.aim -= movement.units
        when :down
            final_position.aim += movement.units
        end
    end

    return final_position
end

def parse_movements(file_name)
    movements = []
    File.open(File.join(File.dirname(__FILE__), file_name)).each do |line|
        split_movement = line.split(" ")

        raise "Direction not found for line: '#{line}'" unless direction = split_movement[0]
        raise "Unknown direction: '#{direction}'" unless DIRECTIONS.include? direction.to_sym
        raise "Unit not found for line: '#{line}'" unless unit = split_movement[1]

        movement = Movement.new
        movement.direction = direction.to_sym
        movement.units = Integer(unit)
        movements.append(movement)
    end
    return movements
end

movements = parse_movements("movements.txt")

initial_position = Position.new
initial_position.horizontal = 0
initial_position.depth = 0
initial_position.aim = 0

final_position = calculate_position(movements, initial_position)

result = final_position.horizontal * final_position.depth
puts "Multiplied result: #{result}"
