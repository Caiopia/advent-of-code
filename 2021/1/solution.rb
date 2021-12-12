# - Common

def parse_measurements(file_name)
    measurements = []
    File.open(File.join(File.dirname(__FILE__), file_name)).each do |line|
        integer_measurement = Integer(line)
        measurements.append(integer_measurement)
    end
    return measurements
end

# - Part one

def num_of_increases(measurements)
    increases = 0
    
    if measurements.empty?
        return 0
    end
    
    previous = measurements.first
    next_measurements = measurements.drop(0)
    for measurement in next_measurements
        increases += 1 if previous < measurement
        previous = measurement
    end

    return increases
end

# - Part two

def num_of_window_increases(measurements, window_size, window_stride)
    window_increases = 0

    if measurements.length < window_size
        return 0
    end

    window_start = 0
    window_end = window_size

    while window_end < measurements.length
        previous_window = measurements.slice(window_start, window_size)
        window_start += window_stride
        window_end += window_stride
        next_window = measurements.slice(window_start, window_size)

        previous_sum = previous_window.sum
        next_sum = next_window.sum

        window_increases += 1 if previous_sum < next_sum
    end

    return window_increases
end

measurements = parse_measurements("measurements.txt")

increases = num_of_increases(measurements)
puts "Number of increases: #{increases}"

window_increases = num_of_window_increases(measurements, 3, 1)
puts "Number of windowed increases: #{window_increases}"
