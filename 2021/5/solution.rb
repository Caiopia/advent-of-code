Point = Struct.new(:x, :y)
Line = Struct.new(:p0, :p1)

def parse_hydrothermal_vents(file_name)
    point_delimiter = "->"
    coordinate_delimiter = ","
    return File.readlines(File.join(File.dirname(__FILE__), file_name)).map { |file_line|
        points = file_line.split(point_delimiter).map { |file_point| 
            coordinates = file_point.strip().split(coordinate_delimiter)
            Point.new(coordinates[0].to_i, coordinates[1].to_i)
        }
        Line.new(points[0], points[1])
    }
end

def line_from_points(line)
    line_points = []

    # Assume 2D everywhere
    x_length = line.p1.x - line.p0.x
    y_length = line.p1.y - line.p0.y
    x_direction = x_length == 0 ? 0 : x_length <=> 0
    y_direction = y_length == 0 ? 0 : y_length <=> 0

    x = line.p0.x
    x_coords = []
    if x_direction.zero?
        x_coords = x_coords + Array.new((y_length + y_direction).abs, x)
    else
        while x != line.p1.x + x_direction
            x_coords << x
            x += x_direction
        end
    end

    y = line.p0.y
    y_coords = []
    if y_direction.zero?
        y_coords = y_coords + Array.new((x_length + x_direction).abs, y)
    else
        while y != line.p1.y + y_direction
            y_coords << y
            y += y_direction
        end
    end

    line_points = x_coords.zip(y_coords)

    return line_points
end

def intersecting_points(vent_coordinates)
    coordinates_seen = {}
    duplicates = 0
    vent_coordinates.each { |coords|
        key = "#{coords[0]}-#{coords[1]}"
        coordinates_seen[key] = (coordinates_seen[key] || 0) + 1
    }
    return coordinates_seen.select { |k, v| v > 1 }
end

vent_lines = parse_hydrothermal_vents("hydrothermal-vents.txt")

# - Part 1

h_v_vent_points = []
vent_lines.filter { |vent_line| vent_line.p0.x == vent_line.p1.x || vent_line.p0.y == vent_line.p1.y}.each { |line|
    h_v_vent_points = h_v_vent_points + line_from_points(line)
}

h_v_intersecting_points = intersecting_points(h_v_vent_points)

puts "Number of horizontal/vertical intersections: #{h_v_intersecting_points.count}"

# - Part 2

vent_points = []
vent_lines.each { |line|
    vent_points = vent_points + line_from_points(line)
}

intersecting_points = intersecting_points(vent_points)

puts "Number of intersections: #{intersecting_points.count}"