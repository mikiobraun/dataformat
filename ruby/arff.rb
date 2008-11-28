# Code to load/write ARFF-files
#
# Initial implementation, still somewhat incomplete:
# 
# - no date/relational attributes
# - no sparse data
# - a bit slow?
#

class String  # :nodoc:
  def truncate(maxlen)
    if length > maxlen
      self[0..maxlen-3] + "..."
    else
      self
    end
  end
end

module ARFF
  # A class for loading and saving ARFF-Files.
  #
  # Currently, handles the following attributes:
  #
  # * real, numeric, integer, string attributes.
  #
  # Date/relational attributes and sparse data is not supported yet.
  #
  # The first comment in a file is available via the +comment+
  # attribute of the class.
  #
  # You can either load a file using ARFF.load or load the
  # data from a string using ARFF.string.
  class ARFFFile
    # The name of the data set.
    attr_accessor :relation
    # The initial comment in the file
    attr_accessor :comment
    # The names of the attributes (use define_attribute to set).
    attr_reader :attribute_names
    # The attribute types (hash) (use define_attribute to set).
    attr_reader :attribute_types
    # Additional data on the types (hash) (use define_attribute
    # to set).
    attr_reader :attribute_data
    # The actual data.
    attr_accessor :data

    # Create new ARFF File.
    def initialize
      @relation = ''
      @comment = []
      @attribute_names = []
      @attribute_types = Hash.new
      @attribute_data = Hash.new
      @data = []
      @state = :comment
    end

    # Define an attribute by its name, type and potentially 
    # further data. (For example, for ordinal types, the possible
    # values.
    def define_attribute(name, type, data=nil)
      @attribute_names << name
      @attribute_types[name] = type
      @attribute_data[name] = data if data
    end

    # Read the type of attribute +name+.
    def attribute_type(name)
      @attribute_types[name]
    end

    # Read the attribute data.
    #def attribute_data(name)
    #  @attribute_data[name]
    #end

    # Load an ARFF file.
    def self.load(file)
      arff = nil
      open(file, 'r') {|f| arff = ARFFFile.parse(f.read) }
      return arff
    end

    # Construct an ARFFFile from a string.
    def self.parse(string)
      arff = ARFFFile.new
      arff.parse_file(string)
      return arff
    end

    # Load contents from a string.
    def parse_file(string)
      string.split("\n").each_with_index do |line, lineno|
        parse_line(line.chomp, lineno+1)
      end
    end

    #######
    private
    #######

    # Parse a single line. Uses a small state machine to keep track of
    # where we are. First comment is collected
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

    # Define an attribute as specified by line.
    def parse_attribute_definition(line, lineno)
      keyword, name, type = line.scan /[a-zA-Z_][a-zA-Z0-9_]*|\{[^\}]+\}|\'[^\']+\'|\"[^\"]+\"/
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
      
    # Define the name of the relation based on line.
    def parse_relation_definition(line, lineno)
      keyword, name = line.scan /[a-zA-Z_][a-zA-Z0-9_]*|\'[^\']+?\'|\"[^\"]+?\"/
      #puts "Relation: #{name}"
      @relation = name
    end

    NUMERIC = /\A\s*[+-]?[0-9]+(?:\.[0-9]*(?:[eE]-?[0-9]+)?)?\s*\Z/

    # Parse data line.
    def parse_data(line, lineno)
      if line[0] == ?{ and line[-1] == ?}
        raise "Sparse data not supported (yet)"
      else
        line = line.split(',').map{|s| s.strip}
        if line.size != @attribute_names.size
          puts "Warning: line #{lineno} does not contain the right number of elements (should be #{attribute_names.size}, got #{line.size})"
          return
        end
        datum = []
        line.zip(@attribute_names).each do |e, a|
          case @attribute_types[a]
          when :numeric
            if e =~ NUMERIC
              datum << e.to_f
            else
              puts "Warning: line #{lineno} uses a non-numeric value \"#{e}\" for attribut \"#{a}\"."
              return
            end
          when :string
            datum << e
          when :nominal
            unless @attribute_data[a].include? e
              puts "Warning: line #{lineno} uses undefined nominal value \"#{e}\" for attribut \"#{a}\"."
              return
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

    # Write the arff file to a file.
    def save(file)
      open(file, "w") {|f| f.write(write)}
    end

    # Write the arfffile to a string.
    def write
      out = []
      out << '% ' + comment.gsub(/\n/m, "\n% ")
      out << "@relation #{write_string(relation)}\n"
      for a in attribute_names
        case attribute_type(a)
        when :numeric
          out << "@attribute #{write_string(a)} numeric"
        when :string
          out << "@attribute #{write_string(a)} string"
        when :nominal
          out << "@attribute #{write_string(a)} {#{attribute_data[a].join(',')}}"
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
