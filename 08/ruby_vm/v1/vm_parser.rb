# rubocop:disable Style/RedundantReturn
# frozen_string_literal: true

# Reads .vm files and parses each line for the VM Translator
class VMParser
  ARITHMETIC_OPTIONS = %w[add sub neg eq gt lt and or not].freeze
  COMMAND_TYPES = [
    [:comment, /(^ *\/\/)/],
    [:empty, /^$/],
    [:push, /push/],
    [:arithmetic, /^add|^sub|^neg|^eq|^gt|^lt|^and|^or|^not/],
    [:pop, /pop/],
    [:label, /^label /],
    [:if_goto, /^if-goto /],
    [:goto, /^goto /],
    [:function, /^function /],
    [:return, /^return/],
    [:call, /^call /]
  ].freeze

  # return :label if @current_line.match(/^label /)
  # return :if_goto if @current_line.match(/^if-goto /)
  # return :goto if @current_line.match(/^goto /)
  # return :function if @current_line.match(/^function /)
  # return :return if @current_line.match(/^return/)
  # return :call if @current_line.match(/^call /)
  attr_reader :current_line, :command_type

  def initialize(path)
    @file = File.open(path, 'r')
    @command_type = nil
  end

  def advance
    @current_line = @file.readline(chomp: true)
    @command_type = parse_command_type
    return @current_line
  end

  def remove_trailing_comments(line)
    line.sub(%r{(?<=\S)\s*//.*$}, '')
  end

  def sanitize_line(line)
    remove_trailing_comments(line).strip
  end

  def more_lines?
    !@file.eof?
  end

  def parse_command_type
    COMMAND_TYPES.each do |type, regex|
      return type if @current_line.match(regex)
    end
  end

  def arg1
    raise StandardError, 'Cannot call #arg1 when command type is :return' if command_type == :return
    raise StandardError, 'Cannot call #arg1 when command type is :empty' if command_type == :empty
    raise StandardError, 'Cannot call #arg1 when command type is :comment' if command_type == :comment
    return @current_line if command_type == :arithmetic

    @current_line.split[1]
  end

  def arg2
    unless %i[pop push function call].include?(command_type)
      raise StandardError, "Cannot call #arg2 with current command type (Expected push, pop, function, or call. Received #{command_type})" # rubocop:disable Layout/LineLength
    end

    @current_line.split[2]
  end
end

# rubocop:enable Style/RedundantReturn
