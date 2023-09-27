class Parser

  attr_reader :current_line

  def initialize(path)
    @file = File.open(path, 'r')
    @current_line = ''
  end

  def command_type
    return :comment if @current_line.match?(/(^\/\/)/)
    return :empty if @current_line.length == 0
    return :a_command if @current_line.include?('@')
    return :l_command if @current_line.match?(/^\([A-Za-z_.$:][A-Za-z0-9_.$:]*\)$/)
    return :c_command if @current_line.match(/[=;]/)
    return :unknown
  end

  def extract_symbol(line)
    command_type = self.command_type
    return line.sub(/@/, "") if command_type == :a_command && !self.a_command_is_const?
    return line.gsub(/[\(\)]/, "") if command_type == :l_command
    return nil
  end

  def symbol
    self.extract_symbol(@current_line)
  end

  def has_more_commands?
    !@file.eof?
  end

  def advance
    line = @file.readline(chomp: true)
    @current_line = self.sanitize_line(line)
    self
  end

  def remove_trailing_comments(line)
    line.sub(/(?<=\S)\s*\/\/.*$/, "")
  end

  def sanitize_line(line)
    throw ArgumentError.new(`invalid argument type (expected String, got #{line.class})`) unless line.class == String
    self.remove_trailing_comments(line.strip)
  end

  def rewind
    @file.pos = 0
  end

  def a_command_to_b
    binary_val = Integer(@current_line.sub(/@/, "")).to_s(2).rjust(15, "0")
    return binary_val
  end

  def a_command_is_const?
    return StandardError.new("current_line is an invalid instruction type (expected :a_command or :l_command, got #{self.command_type.to_s})") unless [:a_command, :l_command].include?(self.command_type)
    !!self.current_line.match?(/^@\d+$/)
  end

  def comp
    return StandardError.new("current_line is of invalid instruction type  (expected :c_command, got #{self.command_type})") unless self.command_type == :c_command
    return self.current_line.split("=").last if(self.current_line.include?("="))
    return self.current_line.split(";").first if self.current_line.include?(";")
  end


  def jump
    return StandardError.new("current_line is an invalid instruction type (expected :c_command, got #{self.command_type})") unless self.command_type == :c_command
    return self.current_line.split(";").last if self.current_line.include?(";")
    return ""
  end

  def dest
    return StandardError.new("current_line is an invalid instruction type (expected :c_command, got #{self.command_type})") unless self.command_type == :c_command
    return self.current_line.split("=").first if self.current_line.include?("=")
    return ""
  end
end
