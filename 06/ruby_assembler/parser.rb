# rubocop:disable Style/RedundantReturn
# frozen_string_literal: true

# Class to parse an assembly file
class Parser
  attr_reader :current_line

  def initialize(path)
    @file = File.open(path, 'r')
    @current_line = ''
  end

  def command_type
    return :comment if @current_line.match?(%r{(^//)})
    return :empty if @current_line.empty?
    return :a_command if @current_line.include?('@')
    return :l_command if @current_line.match?(/^\([A-Za-z_.$:][A-Za-z0-9_.$:]*\)$/)
    return :c_command if @current_line.match(/[=;]/) # rubocop:disable Layout/EmptyLineAfterGuardClause
    return :unknown
  end

  def extract_symbol(line)
    command_type = self.command_type
    return line.sub(/@/, '') if command_type == :a_command && !a_command_is_const?
    return line.gsub(/[()]/, '') if command_type == :l_command

    return nil
  end

  def symbol
    extract_symbol(@current_line)
  end

  def more_commands?
    !@file.eof?
  end

  def advance
    line = @file.readline(chomp: true)
    @current_line = sanitize_line(line)
  end

  def remove_trailing_comments(line)
    line.sub(%r{(?<=\S)\s*//.*$}, '')
  end

  def sanitize_line(line)
    unless line.instance_of?(String)
      throw ArgumentError.new(`Invalid argument type (expected String, got #{line.class})`)
    end
    remove_trailing_comments(line.strip)
  end

  def rewind
    @file.pos = 0
  end

  def a_command_to_b
    binary_val = Integer(@current_line.sub(/@/, '')).to_s(2).rjust(15, '0')
    return binary_val
  end

  def a_command_is_const?
    unless %i[a_command l_command].include?(command_type)
      return StandardError.new("current_line is an invalid instruction type (expected :a_command or :l_command, got #{command_type})") # rubocop:disable Layout/LineLength
    end

    !!current_line.match?(/^@\d+$/)
  end

  def comp
    unless command_type == :c_command
      return StandardError.new("current_line is of invalid instruction type  (expected :c_command, got #{command_type})") # rubocop:disable Layout/LineLength
    end
    return current_line.split('=').last if current_line.include?('=')
    return current_line.split(';').first if current_line.include?(';')
  end

  def jump
    unless command_type == :c_command
      return StandardError.new("current_line is an invalid instruction type (expected :c_command, got #{command_type})")
    end
    return current_line.split(';').last if current_line.include?(';')

    return ''
  end

  def dest
    unless command_type == :c_command
      return StandardError.new("current_line is an invalid instruction type (expected :c_command, got #{command_type})")
    end
    return current_line.split('=').first if current_line.include?('=')

    return ''
  end
end

# rubocop:enable Style/RedundantReturn
