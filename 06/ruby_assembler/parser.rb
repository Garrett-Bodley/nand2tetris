class Parser

  attr_reader :current_line

  def initialize(path)
    @file = File.open(path, 'r')
    @line_num = 1
    @machine_code_line_num = 0
    @current_line = ''
  end

  def command_type(string)
    return :comment if string.match?(/(^\/\/)/)
    return :empty if string.length == 0
    return :a_command if string.include?('@')
    return :l_command if string.match?(/^\([A-Za-z_.$:][A-Za-z0-9_.$:]*\)$/)
    return :c_command if string.match(/[=;]/)
  end

  def symbol(line)
    command_type = self.command_type(line)
    return line.sub(/@/, "") if command_type == :a_command
    return line.gsub(/[\(\)]/, "") if command_type == :l_command
    return nil
  end

  def has_more_commands?
    !@file.eof?
  end

  def advance
    @line_num += 1
    line = @file.readline(chomp: true)
    @current_line = self.sanitize_line(line)
  end

  def remove_trailing_comments(line)
    line.sub(/(?<=\S)\s*\/\/.*$/, "")
  end

  def sanitize_line(line)
    throw ArgumentError.new(`invalid argument type (expected String, got #{line.class})`) unless line.class == String
    self.remove_trailing_comments(line.strip)
  end

  def line_num
    @line_num
  end

  def rewind
    @file.pos = 0
    @line_num = 1
  end
end
