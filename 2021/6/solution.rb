
def parse_lanternfish(file_name, reproduce_cycle_length, reproduce_cycle_offspring_latency)
    lanternfish = []
    lanternfish_delimiter = ","
    File.readlines(File.join(File.dirname(__FILE__), file_name)).each { |file_line|
        # In case they're ever on multiple lines?
        current_lanternfish = file_line.split(lanternfish_delimiter).map { |time_to_reproduce| time_to_reproduce }
        lanternfish.push(*current_lanternfish)
    }
    return lanternfish
end

def multiply_lanternfish(lanternfish, num_days, reproduction_days, new_reproduction_days)
    lanternfish_timers = lanternfish.sort.tally
    day = 1
    while day <= num_days
        old_timers = []
        new_timers = []
        max_range = [reproduction_days, new_reproduction_days].max
        range = (0..max_range)

        # Extract the previous day's values
        range.each { |num|
            old_timers[num] = !lanternfish_timers["#{num}"].nil? ? lanternfish_timers["#{num}"] : 0 if num <= reproduction_days
            new_timers[num] = !lanternfish_timers["new#{num}"].nil? ? lanternfish_timers["new#{num}"] : 0 if num <= new_reproduction_days
        }
        
        # Progress the day by shifting all timers down an index, effectively decreasing them.
        # e.g. lanternfish_timers at key "1" get moved to key "0", timers at key "0" get duplicated and moved to key "6" and "new8".
        range.each { |num|
            index = (num + 1) % (reproduction_days + 1)
            lanternfish_timers["#{num}"] = old_timers[index] if num <= reproduction_days
            lanternfish_timers["#{num}"] += new_timers[index] if num == reproduction_days

            new_index = (num + 1) % (new_reproduction_days + 1)
            lanternfish_timers["new#{num}"] = new_timers[new_index] if num <= new_reproduction_days
            lanternfish_timers["new#{num}"] += old_timers[new_index] if num == new_reproduction_days 
        }       

        day += 1
    end
    return lanternfish_timers.values.sum
end

reproduction_days = 6
new_reproduction_days = 8
initial_lanternfish = parse_lanternfish("lanternfish.txt", reproduction_days, new_reproduction_days)
num_days = 256
lanternfish_after_num_days = multiply_lanternfish(initial_lanternfish, num_days, reproduction_days, new_reproduction_days)
puts "Number of lanternfish after #{num_days} days: #{lanternfish_after_num_days}"

