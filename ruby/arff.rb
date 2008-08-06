# Code to load/write ARFF-files
#
# Initial implementation, still somewhat incomplete:
# 
# - no date/relational attributes
# - no sparse data
# - a bit slow?
#

class String
  def truncate(maxlen)
    if length > maxlen
      self[0..maxlen-3] + "..."
    else
      self
    end
  end
end

module ARFF
  class ARFFFile
    attr_accessor :relation, :comment
    attr_reader :attribute_names, :data

    def initialize
      @relation = ''
      @comment = []
      @attribute_names = []
      @attribute_types = Hash.new
      @attribute_data = Hash.new
      @data = []
    end

    def define_attribute(name, type, data=nil)
      @attribute_names << name
      @attribute_types[name] = type
      @attribute_data[name] = data if data
    end

    def attribute_type(name)
      @attribute_types[name]
    end

    def attribute_data(name)
      @attribute_data[name]
    end

    # Load a file
    def load(file)
      @state = :comment
      open(file, 'r') {|f| parse(f.read) }
    end

    def parse(string)
      string.split("\n").each_with_index do |line, lineno|
        parse_line(line.chomp, lineno+1)
      end
    end

    private

    # Parse a single line. Uses a small state machine to keep track of where we are
    def parse_line(line, lineno)
      case @state
      when :comment
        if line =~ /^%/
          @comment << line[2..-1]
        else
          @comment = @comment.join("\n")
          @state = :in_header
          parse_line(line, lineno)
        end
      when :in_header
        case line.downcase
        when /^@relation/i
          parse_relation_definition(line, lineno)
        when /^@attribute/i
          parse_attribute_definition(line, lineno)
        when /^@data/i
          @state = :data_section
        end
      when :data_section
        unless line =~ /^%/ or line.strip.size == 0
          parse_data(line, lineno)
        end
      end
    end

    # Define an attribute as specified by line
    def parse_attribute_definition(line, lineno)
      keyword, name, type = line.scan /[a-zA-Z_][a-zA-Z0-9_]*|\{[^\}]+\}|\'[^\']+\'|\"[^\"]+\"/
      #puts "Attribute: #{name} type: #{type}"
      name = name[1...-1] if name[0] == ?' and name[-1] == ?'
      name = name[1...-1] if name[0] == ?" and name[-1] == ?"
      if type.downcase == 'real' or
          type.downcase == 'numeric' or
          type.downcase == 'integer'
        define_attribute(name, :numeric)
      elsif type.downcase == 'string'
        define_attribute(name, :string)
      elsif type =~ /\{([^\}]+)\}/
        define_attribute(name, :nominal, $1.split(',').map {|s| s.strip})
      else
        raise "Attributes of type \"#{type}\" not supported (yet)"
      end
    end
      
    # Define the name of the relation based on line
    def parse_relation_definition(line, lineno)
      keyword, name = line.scan /[a-zA-Z_][a-zA-Z0-9_]*|\'[^\']+\'|\"[^\"]+\"/
      #puts "Relation: #{name}"
      @relation = name
    end

    # Parse data line
    def parse_data(line, lineno)
      if line[0] == ?{ and line[-1] == ?}
        raise "Sparse data not supported (yet)"
      else
        line = line.split(',').map{|s| s.strip}
        if line.size != @attribute_names.size
          puts "Warning: line #{lineno} does not contain the right number of elements."
        end
        datum = []
        line.zip(@attribute_names).each do |e, a|
          case @attribute_types[a]
          when :numeric
            datum << e.to_f
          when :string
            datum << e
          when :nominal
            unless @attribute_data[a].include? e
              puts "Warning: line #{lineno} uses an undefined nominal value for attribut \"#{a}\"."
            end
            datum << e
          end
        end
        @data << datum
      end
    end

    ######
    public
    ######

    # generate a somewhat informative representation
    def dump
      s = []
      s << "ARFF File representing relation \"#{@relation}\" with #{@data.length} data points"
      s << ""
      s << "Attributes:"
      for a in @attribute_names
        case @attribute_types[a]
        when :numeric
          s << "  numeric attribute #{a}"
        when :string
          s << "  string attribute #{a}"
        when :nominal
          s << "  nominal attribute #{a} with values #{@attribute_data[a].join ', '}"
        end
      end
      s << ""
      s << "Comment starts with:"
      s << "  > " + @comment[0..200].gsub(/\n/m, "\n  > ") + "..."
      s << ""
      s << "First 5 data points:"
      for d in @data[0...5]
        s << d.map{|e| e.to_s}.join(', ').truncate(70)
      end
      s.join "\n"
    end

    # write the arff file to a file
    def save(file)
      open(file, "w") {|f| f.write(write)}
    end

    # write the arfffile to a string
    def write
      out = []
      out << '% ' + comment.gsub(/\n/m, "\n% ")
      out << "@relation #{write_string(relation)}\n"
      for a in attribute_names
        case attribute_type(a)
        when :numeric
          out << "@attribute #{write_string(a)} numeric"
        when :string
          out << "@attribute #{write_string(a)} numeric"
        when :nominal
          out << "@attribute #{write_string(a)} {#{attribute_data(a).join(',')}}"
        end
      end
      out << "\n@data"
      for d in data
        line = []
        d.zip(attribute_names).each do |e, a|
          case attribute_type(a)
          when :numeric
            line << e.to_s
          when :string
            line << write_string(e)
          when :nominal
            line << e
          end
        end
        out << line.join(',')
      end
      out.join("\n") + "\n"
    end

    #######
    private
    #######

    # write a string. encapsulate it in 's if it contains spaces
    def write_string(s)
      if s =~ /\s/
        '\'' + s + '\''
      else
        s
      end
    end
  end
end

if __FILE__ == $0
  require 'pp'
  Dir.glob('../examples/*.arff').each do |file|
    puts '-' * 70
    a = ARFF::ARFFFile.new
    a.load(file)
    puts a.dump
    a.save('temp.arff')
    b = ARFF::ARFFFile.new
    b.load('temp.arff')
    puts b.dump
  end
end
