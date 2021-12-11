# - Common

def parseMeasurements(fileName)
    measurements = []
    File.open(fileName).each do |line|
        integerMeasurement = Integer(line)
        measurements.append(integerMeasurement)
    end
    return measurements
end

# - Part one

def numOfIncreases(measurements)
    increases = 0
    
    if measurements.empty?
        return 0
    end
    
    previous = measurements.first
    nextMeasurements = measurements.drop(0)
    for measurement in nextMeasurements
        increases += 1 if previous < measurement
        previous = measurement
    end

    return increases
end

# - Part two

def numOfWindowIncreases(measurements, windowSize, windowStride)
    windowIncreases = 0

    if measurements.length < windowSize
        return 0
    end

    windowStart = 0
    windowEnd = windowSize

    while windowEnd < measurements.length
        previousWindow = measurements.slice(windowStart, windowSize)
        windowStart += windowStride
        windowEnd += windowStride
        nextWindow = measurements.slice(windowStart, windowSize)

        previousSum = previousWindow.sum
        nextSum = nextWindow.sum

        windowIncreases += 1 if previousSum < nextSum
    end

    return windowIncreases
end

measurements = parseMeasurements("measurements.txt")

increases = numOfIncreases(measurements)
puts "Number of increases: #{increases}"

windowIncreases = numOfWindowIncreases(measurements, 3, 1)
puts "Number of windowed increases: #{windowIncreases}"
