# - Common

DiagnosticReport = Struct.new(:binary_numbers, :number_of_bits)

def parse_diagnostic_report(file_name)
    binary_numbers = []
    File.open(File.join(File.dirname(__FILE__), file_name)).each do |line|
        binary_numbers.append(line.strip())
    end

    # validate report
    raise "No codes in diagnostic report" if binary_numbers.empty?

    number_of_bits = binary_numbers.first.length
    for binary_number in binary_numbers
        raise "Differently sized codes in diagnostic report" unless binary_number.length == number_of_bits
    end

    diagnostic_report = DiagnosticReport.new
    diagnostic_report.binary_numbers = binary_numbers
    diagnostic_report.number_of_bits = number_of_bits

    return diagnostic_report
end

def bits_at_index(binary_numbers, index)
    bits_at_index = Hash.new(0)
    for binary_number in binary_numbers
        bit_at_index = binary_number[index]
        bits_at_index[bit_at_index] += 1
    end

    return bits_at_index
end

# - Part 1

def calculate_gamma_rate(diagnostic_report)
    gamma_rate = ""
    for index in 0...diagnostic_report.number_of_bits 
        bits_at_index = bits_at_index(diagnostic_report.binary_numbers, index)
        most_common_bit_at_index = bits_at_index.key(bits_at_index.values.max)
        gamma_rate.concat(most_common_bit_at_index)
    end

    return gamma_rate
end

def calculate_epsilon_rate(diagnostic_report)
    epsilon_rate = ""
    for index in 0...diagnostic_report.number_of_bits 
        bits_at_index = bits_at_index(diagnostic_report.binary_numbers, index)
        least_common_bit_at_index = bits_at_index.key(bits_at_index.values.min)
        epsilon_rate.concat(least_common_bit_at_index)
    end

    return epsilon_rate
end

def calculate_power_consumption(diagnostic_report)
    gamma_rate = calculate_gamma_rate(diagnostic_report)
    epsilon_rate = calculate_epsilon_rate(diagnostic_report)
    power_consumption = gamma_rate.to_i(2) * epsilon_rate.to_i(2)

    return power_consumption
end

# - Part 2

def filter_diagnostic_report(diagnostic_report, bit_criteria)
    candidates = diagnostic_report.binary_numbers
    for index in 0...diagnostic_report.number_of_bits
        break if candidates.length == 1
        condition_bit = bit_criteria.call(candidates, index)
        candidates = candidates.select { |candidate| candidate[index] == condition_bit }
    end

    return candidates
end

def calculate_oxygen_generator_rating(diagnostic_report)
    bit_criteria = -> (candidates, index) {
        bits_at_index = bits_at_index(candidates, index)
        most_common_bit_at_index = bits_at_index.values.uniq.length != 1 ? bits_at_index.key(bits_at_index.values.max) : "1"
        return most_common_bit_at_index
    }

    oxygen_generator_rating_candidates = filter_diagnostic_report(diagnostic_report, bit_criteria)

    raise "Found multiple candidates for oxygen generator rating: #{oxygen_generator_rating_candidates}" unless oxygen_generator_rating_candidates.length == 1
    return oxygen_generator_rating_candidates.first
end

def calculate_co2_scrubber_rating(diagnostic_report)
    bit_criteria = -> (candidates, index) {
        bits_at_index = bits_at_index(candidates, index)
        least_common_bit_at_index = bits_at_index.values.uniq.length != 1 ? bits_at_index.key(bits_at_index.values.min) : "0"
        return least_common_bit_at_index
    }

    co2_scrubber_rating_candidates = filter_diagnostic_report(diagnostic_report, bit_criteria)

    raise "Found multiple candidates for CO2 scrubber rating: #{co2_scrubber_rating_candidates}" unless co2_scrubber_rating_candidates.length == 1
    return co2_scrubber_rating_candidates.first
end

def calculate_life_support_rating(diagnostic_report)
    oxygen_generator_rating = calculate_oxygen_generator_rating(diagnostic_report)    
    co2_scrubber_rating = calculate_co2_scrubber_rating(diagnostic_report)
    life_support_rating = oxygen_generator_rating.to_i(2) * co2_scrubber_rating.to_i(2)

    return life_support_rating
end

diagnostic_report = parse_diagnostic_report("diagnostic-report.txt")

power_consumption = calculate_power_consumption(diagnostic_report)
puts "Power consumption: #{power_consumption}"

life_support_rating = calculate_life_support_rating(diagnostic_report)
puts "Life support rating: #{life_support_rating}"
