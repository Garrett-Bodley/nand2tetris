# rubocop:disable Metrics/MethodLength
# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter
  ARITHMETIC_OPTIONS = %w[add sub neg eq gt lt and or not].freeze
  SYMBOL_TABLE = {
    eq: 'JEQ',
    lt: 'JLT',
    gt: 'JGT',
    add: '+',
    sub: '-',
    and: '&',
    or: '|',
    neg: '-',
    not: '!'
  }.freeze

  def initialize(path)
    @output_file = File.open(path, 'w')
    @basename = path.basename('.*').to_s
    @label_count = 0
  end

  def write_push_pop(command_type, segment, index)
    write_push(segment.to_sym, index) if command_type == :push

  end

  def write_push(segment, val)
    write_constant(val) if segment == :constant
  end

  def write_constant(val)
    # load new val into D
    @output_file.puts "@#{val}"
    @output_file.puts 'D=A'
    # set A to SP
    @output_file.puts '@SP'
    # set A to RAM[SP] (ADDRESS SP POINTS TO) THIS IS AN AVAILABLE ADDRESS
    @output_file.puts 'A=M'
    # WRITE VAL TO TOP OF STACK
    @output_file.puts 'M=D'
    # INCREMENT SP
    @output_file.puts '@SP'
    @output_file.puts 'M=M+1'
  end

  def write_arithmetic(string)
    string_sym = string.to_sym
    case string_sym
    when :add, :sub
      write_add_subtract(SYMBOL_TABLE[string_sym])
    when :neg, :not
      write_neg_not(SYMBOL_TABLE[string_sym])
    when :eq, :lt, :gt
      write_arithmetic_comparison(SYMBOL_TABLE[string_sym])
    when :and, :or
      write_and_or(SYMBOL_TABLE[string_sym])
    end
  end

  def write_add_subtract(operator)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=M#{operator}D"
    ].each do |instruction|
      @output_file.puts instruction
    end
  end

  def write_arithmetic_comparison(comp_type)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      'D=M-D',
      "@#{@basename}.#{@label_count}",
      "D;#{comp_type}",
      '@0',
      'D=A',
      "@#{@basename}.#{@label_count + 1}",
      '0;JMP',
      "(#{@basename}.#{@label_count})",
      '@0',
      'A=A-1',
      'D=A',
      "(#{@basename}.#{@label_count + 1})",
      '@SP',
      'A=M-1',
      'M=D'
    ].each do |command|
      @output_file.puts command
    end
    @label_count += 2
  end

  def write_and_or(operator)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=D#{operator}M"
    ].each do |command|
      @output_file.puts command
    end
  end

  def write_neg_not(operator)
    @output_file.puts '// WRITING NEG'
    [
      '@SP',
      'A=M-1',
      "M=#{operator}M"
    ].each do |command|
      @output_file.puts command
    end
  end

  def write_infinite_loop
    @output_file.puts '(INFINITE_LOOP)'
    @output_file.puts '@INFINITE_LOOP'
    @output_file.puts '0; JMP'
  end
end



# PUSH CONSTANT 7
#
# LOAD 3 INTO D REGISTER
# @7
# D = A
# GET ADDRESS IN STACK POINTER
# @STACK_POINTER
# A = M
# PUSH 3 ONTO STACK
# M = D
# INCREMENT SP
# @STACK_POINTER
# M = M + 1

# rubocop:enable Metrics/MethodLength
