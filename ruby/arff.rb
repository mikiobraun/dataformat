module ARFF
  class ARFFLoader
    def load(file)
      @state = :collecting_comment
      @first_comment = []
      open(file, "r").readlines do |line|
        parse_line(line)
      end
    end

    def parse_line(line)
      case @state
      when :collecting_comment
        if line ~= /^%/
          @first_comment << line[2:-1]
        else
          @state = :in_header
          parse_line(line)
        end
      when :in_header
        case line.downcase
        when /^@relation/
          define_relation line
        when /^@attribute/
          define_attribute line
        when /^@data/
          @stat = :data_section
        end
      when :data_section
        parse_data line
      end
    end

    def define_attribute(line)
      words = line.split
      puts "Attribute: #{words[1]} type: #{words[2]}"
    end

    def define_relation(line)
      words = line.split
      puts "Relation: #{words[1]}"
    end
  end
end
