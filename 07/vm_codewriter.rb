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

  SEGMENT_TABLE = {
    local: 'LCL',
    argument: 'ARG',
    this: 'THIS',
    that: 'THAT',
    pointer: 'THIS',
    temp: 'TEMP'
  }.freeze

  def initialize(path)
    @file = File.open(path, 'w')
    @basename = path.basename('.*').to_s
    @label_count = 0
  end

  def write_push_pop(command_type, segment, index)
    seg_sym = segment.to_sym
    write_push(segment.to_sym, index) if command_type == :push
    write_pop_to_segment(SEGMENT_TABLE[seg_sym], index) if command_type == :pop
  end

  def write_push(segment, val)
    return push_constant(val) if segment == :constant

    push_from_segment(SEGMENT_TABLE[segment], val)
  end

  def push_constant(val)
    # load new val into D
    @file.puts "@#{val}"
    @file.puts 'D=A'
    # set A to SP
    @file.puts '@SP'
    # set A to RAM[SP] (ADDRESS SP POINTS TO) THIS IS AN AVAILABLE ADDRESS
    @file.puts 'A=M'
    # WRITE VAL TO TOP OF STACK
    @file.puts 'M=D'
    # INCREMENT SP
    @file.puts '@SP'
    @file.puts 'M=M+1'
  end

  def push_from_segment(segment, val)
    return push_from_temp(val) if segment == 'TEMP'

    @file.puts '// PUSHING FROM SEGMENT'
    [
      "@#{segment}",
      'A=M',
      'D=A',
      "@#{val}",
      'A=D+A',
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ].each do |instruction|
      @file.puts instruction
    end
  end

  def push_from_temp(val)
    [
      "@#{5 + val.to_i}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ].each do |instruction|
      @file.puts instruction
    end
  end

  def write_pop_to_segment(segment, val)
    return write_pop_to_temp(val) if segment == 'TEMP'

    @file.puts "// POPPING TO SEGMENT: #{segment}"
    [
      "@#{segment}",
      'D=M',
      "@#{val}",
      'D=D+A',
      '@13',
      'M=D',
      '@SP',
      'AM=M-1',
      'D=M',
      '@13',
      'A=M',
      'M=D'
    ].each do |instruction|
      @file.puts instruction
    end
  end

  def write_pop_to_temp(val)
    @file.puts '// POPPING TO TEMP'
    [
      "@#{5 + val.to_i}",
      'D=A',
      '@13',
      'M=D',
      '@SP',
      'AM=M-1',
      'D=M',
      '@13',
      'A=M',
      'M=D'
    ].each do |instruction|
      @file.puts instruction
    end
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
      @file.puts instruction
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
      @file.puts command
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
      @file.puts command
    end
  end

  def write_neg_not(operator)
    @file.puts '// WRITING NEG'
    [
      '@SP',
      'A=M-1',
      "M=#{operator}M"
    ].each do |command|
      @file.puts command
    end
  end

  def write_infinite_loop
    @file.puts '(INFINITE_LOOP)'
    @file.puts '@INFINITE_LOOP'
    @file.puts '0; JMP'
  end
end

# rubocop:enable Metrics/MethodLength
