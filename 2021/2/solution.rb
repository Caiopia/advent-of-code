DIRECTIONS = [:forward, :up, :down]

Movement = Struct.new(:direction, :units)
Position = Struct.new(:horizontal, :depth, :aim)

def calculatePosition(movements, initialPosition)
    finalPosition = initialPosition
    for movement in movements
        case movement.direction
        when :forward
            finalPosition.horizontal += movement.units
            finalPosition.depth += finalPosition.aim * movement.units
        when :up
            finalPosition.aim -= movement.units
        when :down
            finalPosition.aim += movement.units
        end
    end

    return finalPosition
end

def parseMovements(fileName)
    movements = []
    File.open(fileName).each do |line|
        splitMovement = line.split(" ")

        raise "Direction not found for line: '#{line}'" unless direction = splitMovement[0]
        raise "Unknown direction: '#{direction}'" unless DIRECTIONS.include? direction.to_sym
        raise "Unit not found for line: '#{line}'" unless unit = splitMovement[1]

        movement = Movement.new
        movement.direction = direction.to_sym
        movement.units = Integer(unit)
        movements.append(movement)
    end
    return movements
end

movements = parseMovements("movements.txt")

initialPosition = Position.new
initialPosition.horizontal = 0
initialPosition.depth = 0
initialPosition.aim = 0

finalPosition = calculatePosition(movements, initialPosition)
puts finalPosition

result = finalPosition.horizontal * finalPosition.depth
puts "Multiplied result: #{result}"
