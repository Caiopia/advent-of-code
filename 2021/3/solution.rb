# - Common

DiagnosticReport = Struct.new(:binaryNumbers, :numberOfBits)

def parseDiagnosticReport(fileName)
    binaryNumbers = []
    File.open(File.join(File.dirname(__FILE__), fileName)).each do |line|
        binaryNumbers.append(line.strip())
    end

    # validate report
    raise "No codes in diagnostic report" if binaryNumbers.empty?

    numberOfBits = binaryNumbers.first.length
    for binaryNumber in binaryNumbers
        raise "Differently sized codes in diagnostic report" unless binaryNumber.length == numberOfBits
    end

    diagnosticReport = DiagnosticReport.new
    diagnosticReport.binaryNumbers = binaryNumbers
    diagnosticReport.numberOfBits = numberOfBits

    return diagnosticReport
end

def bitsAtIndex(binaryNumbers, index)
    bitsAtIndex = Hash.new(0)
    for binaryNumber in binaryNumbers
        bitAtIndex = binaryNumber[index]
        bitsAtIndex[bitAtIndex] += 1
    end

    return bitsAtIndex
end

# - Part 1

def calculateGammaRate(diagnosticReport)
    gammaRate = ""
    for index in 0...diagnosticReport.numberOfBits 
        bitsAtIndex = bitsAtIndex(diagnosticReport.binaryNumbers, index)
        mostCommonBitAtIndex = bitsAtIndex.key(bitsAtIndex.values.max)
        gammaRate.concat(mostCommonBitAtIndex)
    end

    return gammaRate
end

def calculateEpsilonRate(diagnosticReport)
    epsilonRate = ""
    for index in 0...diagnosticReport.numberOfBits 
        bitsAtIndex = bitsAtIndex(diagnosticReport.binaryNumbers, index)
        leastCommonBitAtIndex = bitsAtIndex.key(bitsAtIndex.values.min)
        epsilonRate.concat(leastCommonBitAtIndex)
    end

    return epsilonRate
end

def calculatePowerConsumption(diagnosticReport)
    gammaRate = calculateGammaRate(diagnosticReport)
    epsilonRate = calculateEpsilonRate(diagnosticReport)
    powerConsumption = gammaRate.to_i(2) * epsilonRate.to_i(2)

    return powerConsumption
end

# - Part 2

def filterDiagnosticReport(diagnosticReport, bitCriteria)
    candidates = diagnosticReport.binaryNumbers
    for index in 0...diagnosticReport.numberOfBits
        break if candidates.length == 1
        conditionBit = bitCriteria.call(candidates, index)
        candidates = candidates.select { |candidate| candidate[index] == conditionBit }
    end

    return candidates
end

def calculateOxygenGeneratorRating(diagnosticReport)
    bitCriteria = -> (candidates, index) {
        bitsAtIndex = bitsAtIndex(candidates, index)
        mostCommonBitAtIndex = bitsAtIndex.values.uniq.length != 1 ? bitsAtIndex.key(bitsAtIndex.values.max) : "1"
        return mostCommonBitAtIndex
    }

    oxygenGeneratorRatingCandidates = filterDiagnosticReport(diagnosticReport, bitCriteria)

    raise "Found multiple candidates for oxygen generator rating: #{oxygenGeneratorRatingCandidates}" unless oxygenGeneratorRatingCandidates.length == 1
    return oxygenGeneratorRatingCandidates.first
end

def calculateCo2ScrubberRating(diagnosticReport)
    bitCriteria = -> (candidates, index) {
        bitsAtIndex = bitsAtIndex(candidates, index)
        leastCommonBitAtIndex = bitsAtIndex.values.uniq.length != 1 ? bitsAtIndex.key(bitsAtIndex.values.min) : "0"
        return leastCommonBitAtIndex
    }

    co2ScrubberRatingCandidates = filterDiagnosticReport(diagnosticReport, bitCriteria)

    raise "Found multiple candidates for CO2 scrubber rating: #{co2ScrubberRatingCandidates}" unless co2ScrubberRatingCandidates.length == 1
    return co2ScrubberRatingCandidates.first
end

def calculateLifeSupportRating(diagnosticReport)
    oxygenGeneratorRating = calculateOxygenGeneratorRating(diagnosticReport)    
    co2ScrubberRating = calculateCo2ScrubberRating(diagnosticReport)
    lifeSupportRating = oxygenGeneratorRating.to_i(2) * co2ScrubberRating.to_i(2)

    return lifeSupportRating
end

diagnosticReport = parseDiagnosticReport("diagnostic-report.txt")

powerConsumption = calculatePowerConsumption(diagnosticReport)
puts "Power consumption: #{powerConsumption}"

lifeSupportRating = calculateLifeSupportRating(diagnosticReport)
puts "Life support rating: #{lifeSupportRating}"
