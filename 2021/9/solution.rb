Coordinates = Struct.new(:x, :y)

class Heightmap

    attr_accessor :hash, :x_length, :y_length

    def initialize(hash, x_length, y_length)
        @hash = hash
        @x_length = x_length
        @y_length = y_length
    end

    def [](key)
        return @hash[key]
    end
end

def parse_heightmap(file_name)
    heightmap_hash = {}
    y = 0
    x = 0
    File.readlines(File.join(File.dirname(__FILE__), file_name)).each_with_index { |file_line, index|
        chars = file_line.chars
        x = 0
        while x < chars.length
            c = chars[x]
            if !c.strip.empty?
                heightmap_hash[key(x, y)] = c.to_i
            end
            x += 1
        end
        y += 1
    }
    heightmap = Heightmap.new(heightmap_hash, x, y)
    return heightmap
end

def key(x, y)
    return "#{x}_#{y}"
end

def low_points(heightmap)
    low_points = {}
    min_rows = 0
    min_columns = 0
    max_rows = heightmap.y_length - 1
    max_columns = heightmap.x_length - 1
    y = 0
    while y <= max_rows
        x = 0
        while x <= max_columns
            current = heightmap[key(x, y)]
            left    = (x > min_columns) ? heightmap[key(x - 1, y)] : nil
            right   = (x < max_columns) ? heightmap[key(x + 1, y)] : nil
            above   = (y > min_rows) ? heightmap[key(x, y - 1)] : nil
            below   = (y < max_rows) ? heightmap[key(x, y + 1)] : nil
            
            is_lowest = true
            is_lowest &= current < above if !above.nil?
            is_lowest &= current < below if !below.nil?
            is_lowest &= current < left if !left.nil?
            is_lowest &= current < right if !right.nil? 
            low_points[key(x, y)] = current if is_lowest
            x += 1
        end
        y += 1
    end
    return low_points
end

def basin_size(heightmap, current_coordinate)
    visited = []
    queue = [current_coordinate]
    while queue.length > 0
        current = queue.shift
        x = current.x
        y = current.y
        key = key(x, y)
        current_value = heightmap[key]
        
        next if current_value == 9 || visited.include?(key)

        visited.push(key)
        neighbours = find_neighbours(heightmap, current)
        queue.push(*neighbours)
    end

    return visited.length
end

def find_neighbours(heightmap, current)
    neighbours = []

    min_rows = 0
    min_columns = 0
    max_rows = heightmap.y_length - 1
    max_columns = heightmap.x_length - 1

    x = current.x
    y = current.y

    current = heightmap[key(x, y)]
    left    = (x > min_columns) ? heightmap[key(x - 1, y)] : nil
    right   = (x < max_columns) ? heightmap[key(x + 1, y)] : nil
    above   = (y > min_rows) ? heightmap[key(x, y - 1)] : nil
    below   = (y < max_rows) ? heightmap[key(x, y + 1)] : nil

    neighbours.push(Coordinates.new(x - 1, y)) if !(left.nil? || left < current)
    neighbours.push(Coordinates.new(x + 1, y)) if !(right.nil? || right < current)
    neighbours.push(Coordinates.new(x, y - 1)) if !(above.nil? || above < current)
    neighbours.push(Coordinates.new(x, y + 1)) if !(below.nil? || below < current)
    
    return neighbours
end

heightmap = parse_heightmap("heightmap.txt")
low_points = low_points(heightmap)

# - Part 1

risk_level_sum = low_points.values.sum + low_points.count
puts "Risk level sum: #{risk_level_sum}"

# - Part 2

basin_sizes = []
low_points.each { |coordinates, height|
    better_coordinates = Coordinates.new(coordinates.split("_")[0].to_i, coordinates.split("_")[1].to_i)
    basin_size = basin_size(heightmap, better_coordinates)
    basin_sizes.push(basin_size)
}.sort.reverse

product_of_top3_basins = basin_sizes.sort.reverse[0..2].inject(:*)
puts "Basin sizes: #{product_of_top3_basins}"