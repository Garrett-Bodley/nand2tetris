# rubocop:disable Style/RedundantReturn
# frozen_string_literal: true

# Reads .vm files and parses each line for the VM Translator
class VMParser
  ARITHMETIC_OPTIONS = %w[add sub neg eq gt lt and or not].freeze

  attr_reader :current_line

  def initialize(path)
    @file = File.open(path, 'r')
  end

  def advance
    @current_line = @file.readline(chomp: true)
  end

  def remove_trailing_comments(line)
    line.sub(%r{(?<=\S)\s*//.*$}, '')
  end

  def sanitize_line(line)
    remove_trailing_comments(line.strip)
  end

  def more_lines?
    !@file.eof?
  end

  def command_type
    return :comment if @current_line.match?(%r{(^//)})
    return :empty if @current_line.empty?
    return :push if @current_line.include?('push')
    return :pop if @current_line.include?('pop')
    return :arithmetic if ARITHMETIC_OPTIONS.any? { |option| @current_line.include?(option) }
  end

  def arg1
    raise StandardError, 'Cannot call #arg1 when command type is :return' if command_type == :return
    return @current_line if command_type == :arithmetic

    @current_line.split[1]
  end

  def arg2
    unless %i[pop push function call].include?(command_type)
      raise StandardError "Cannot call #arg2 with current command type (Expected push, pop, function, or call. Received #{command_type})" # rubocop:disable Layout/LineLength
    end

    @current_line.split[2]
  end
end

# rubocop:enable Style/RedundantReturn
