# rubocop:disable Metrics/MethodLength
# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter # rubocop:disable Metrics/ClassLength
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
    temp: 'TEMP'
  }.freeze

  def initialize(path)
    @file = File.open(path, 'w')
    @basename = path.basename('.*').to_s
    @compare_count = 0
  end

  def write_push_pop(command_type, segment, index)
    seg_sym = segment.to_sym
    write_push(seg_sym, index) if command_type == :push
    write_pop(seg_sym, index) if command_type == :pop
  end

  def write_push(seg_sym, val)
    return push_constant(val) if seg_sym == :constant
    return push_pointer(val) if seg_sym == :pointer
    return push_static(val) if seg_sym == :static

    push_from_segment(SEGMENT_TABLE[seg_sym], val)
  end

  def write_pop(seg_sym, val)
    return pop_to_temp(val) if seg_sym == :temp
    return pop_to_pointer(val) if seg_sym == :pointer
    return pop_to_static(val) if seg_sym == :static

    pop_to_segment(SEGMENT_TABLE[seg_sym], val)
  end

  def push_static(val)
    instructions = [
      "@#{@basename}.#{val}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
    write_instructions(instructions)
  end

  def pop_to_static(val)
    instructions = [
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{@basename}.#{val}",
      'M=D'
    ]
    write_instructions(instructions)
  end

  def pop_to_pointer(val)
    address = 'THIS' if val == '0'
    address = 'THAT' if val == '1'
    instructions = [
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{address}",
      'M=D'
    ]
    write_instructions(instructions)
  end

  def push_pointer(val)
    # Any access to pointer 0 should result in accessing the THIS pointer, and any access to pointer 1 should result in accessing the THAT pointer
    # For example, pop pointer 0 should set THIS to the popped value
    # push pointer 1 should push onto the stack the current value of THAT
    load_address = 'THIS' if val == '0'
    load_address = 'THAT' if val == '1'
    instructions = [
      "@#{load_address}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
    write_instructions(instructions)
  end

  def push_constant(val)
    instructions = [
      "@#{val}",
      'D=A',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]

    write_instructions(instructions)
  end

  def push_from_segment(segment, val)
    return push_from_temp(val) if segment == 'TEMP'

    instructions = [
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
    ]
    write_instructions(instructions)
  end

  def push_from_temp(val)
    instructions = [
      "@#{5 + val.to_i}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
    write_instructions(instructions)
  end

  def pop_to_segment(segment, val)
    return pop_to_temp(val) if segment == 'TEMP'

    instructions = [
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
    ]

    write_instructions(instructions)
  end

  def pop_to_temp(val)
    instructions = [
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
    ]
    write_instructions(instructions)
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
    instructions = [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=M#{operator}D"
    ]
    write_instructions(instructions)
  end

  def write_arithmetic_comparison(comp_type)
    instructions = [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      'D=M-D',
      "@COMPARE.#{@compare_count}",
      "D;#{comp_type}",
      '@0',
      'D=A',
      "@COMPARE.#{@compare_count + 1}",
      '0;JMP',
      "(COMPARE.#{@compare_count})",
      '@0',
      'A=A-1',
      'D=A',
      "(COMPARE.#{@compare_count + 1})",
      '@SP',
      'A=M-1',
      'M=D'
    ]
    write_instructions(instructions)
    @compare_count += 2
  end

  def write_and_or(operator)
    instructions = [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=D#{operator}M"
    ]
    write_instructions(instructions)
  end

  def write_neg_not(operator)
    instructions = [
      '@SP',
      'A=M-1',
      "M=#{operator}M"
    ]
    write_instructions(instructions)
  end

  def write_instructions(instruction_arr)
    instruction_arr.each do |instruction|
      @file.puts instruction
    end
  end

  def write_infinite_loop
    @file.puts '(INFINITE_LOOP)'
    @file.puts '@INFINITE_LOOP'
    @file.puts '0; JMP'
  end
end

# rubocop:enable Metrics/MethodLength
