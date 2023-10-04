# rubocop:disable Metrics/MethodLength, Style/RedundantReturn
# frozen_string_literal: true

# Class that translates arithmetic stack operations
class VMArithmeticTranslator
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

  def initialize
    @compare_count = 0
  end

  def translate(operation_sym)
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
    return instructions
  end

  def add_subtract(operator)
    [
      '@SP',
      'AM=M-1',
      'D=M',
      'A=A-1',
      "M=M#{operator}D"
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
end

# rubocop:enable Metrics/MethodLength, Style/RedundantReturn
