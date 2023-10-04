# rubocop:disable Metrics/MethodLength
# frozen_string_literal: true

# Writes VM Code
class VMCodeWriter # rubocop:disable Metrics/ClassLength
  ARITHMETIC_OPTIONS = %w[add sub neg eq gt lt and or not].freeze
  MATH_TABLE = {
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

  def write_push_pop(command_type, seg_sym, index)
    write_push(seg_sym, index) if command_type == :push
    write_pop(seg_sym, index) if command_type == :pop
  end

  def write_push(seg_sym, val)
    case seg_sym
    when :constant
      instructions = push_constant(val)
    when :pointer
      instructions = push_pointer(val)
    when :static
      instructions = push_static(val)
    when :temp
      instructions = push_from_temp(val)
    when :local, :argument, :this, :that
      instructions = push_from_segment(seg_sym, val)
    end
    write_instructions(instructions)
  end

  def push_constant(val)
    [
      "@#{val}",
      'D=A',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
  end

  def push_pointer(val)
    # Any access to pointer 0 should result in accessing the THIS pointer
    # Any access to pointer 1 should result in accessing the THAT pointer
    # For example, pop pointer 0 should set THIS to the popped value
    # push pointer 1 should push onto the stack the current value of THAT
    load_address = val.to_i.zero? ? 'THIS' : 'THAT'
    [
      "@#{load_address}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
  end

  def push_static(val)
    [
      "@#{@basename}.#{val}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1'
    ]
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
    ]
  end

  def push_from_segment(segment, val)
    [
      "@#{SEGMENT_TABLE[segment]}",
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
  end

  def write_pop(seg_sym, val)
    case seg_sym
    when :temp
      instructions = pop_to_temp(val)
    when :pointer
      instructions = pop_to_pointer(val)
    when :static
      instructions = pop_to_static(val)
    when :local, :argument, :this, :that
      instructions = pop_to_segment(SEGMENT_TABLE[seg_sym], val)
    end
    write_instructions(instructions)
  end

  def pop_to_temp(val)
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
    ]
  end

  def pop_to_pointer(val)
    address = 'THIS' if val == '0'
    address = 'THAT' if val == '1'
    [
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{address}",
      'M=D'
    ]
  end

  def pop_to_static(val)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{@basename}.#{val}",
      'M=D'
    ]
  end

  def pop_to_segment(segment, val)
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
    ]
  end

  def write_arithmetic(operation_sym)
    case operation_sym
    when :add, :sub
      instructions = add_subtract(MATH_TABLE[operation_sym])
    when :neg, :not
      instructions = neg_not(MATH_TABLE[operation_sym])
    when :and, :or
      instructions = and_or(MATH_TABLE[operation_sym])
    when :eq, :lt, :gt
      instructions = arithmetic_comparison(MATH_TABLE[operation_sym])
    end
    write_instructions(instructions)
  end

  def add_subtract(op_string)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=M#{op_string}D"
    ]
  end

  def neg_not(operator)
    [
      '@SP',
      'A=M-1',
      "M=#{operator}M"
    ]
  end

  def and_or(operator)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=D#{operator}M"
    ]
  end

  def arithmetic_comparison(comp_type)
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
    @compare_count += 2
    return instructions
  end

  def write_infinite_loop
    instructions = [
      '(INFINITE_LOOP)',
      '@INFINITE_LOOP',
      '0; JMP'
    ]
    write_instructions(instructions)
  end

  def write_instructions(instruction_arr)
    instruction_arr.each do |instruction|
      @file.puts instruction
    end
  end
end

# rubocop:enable Metrics/MethodLength
