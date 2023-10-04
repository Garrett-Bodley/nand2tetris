# rubocop:disable Metrics/MethodLength, Style/RedundantReturn
# frozen_string_literal: true

# A class for writing push and pop operations
class VMPushPopTranslator # rubocop:disable Metrics/ClassLength
  attr_accessor :filename

  SEGMENT_TABLE = {
    local: 'LCL',
    argument: 'ARG',
    this: 'THIS',
    that: 'THAT',
    temp: 'TEMP'
  }.freeze

  def initialize(filename)
    @filename = filename
  end

  def translate(command_type, seg_sym, index)
    case command_type
    when :push
      instructions = push(seg_sym, index)
    when :pop
      instructions = pop(seg_sym, index)
    end

    return instructions
  end

  def push(seg_sym, val)
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
    return instructions
  end

  def push_constant(val)
    [
      '// Push Constant',
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
      '// Push Pointer',
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
      '// Push Static',
      "@#{@filename}.#{val}",
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
      '// Push from temp',
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
    if val == '0'
      instructions = [
        "// Push from segment: #{segment}",
        "@#{SEGMENT_TABLE[segment]}",
        'A=M',
        'D=M',
        '@SP',
        'A=M',
        'M=D',
        '@SP',
        'M=M+1'
      ]
    else
      instructions = [
        "// Push from segment: #{segment}",
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
    return instructions
  end

  def pop(seg_sym, val)
    case seg_sym
    when :temp
      instructions = pop_to_temp(val)
    when :pointer
      instructions = pop_to_pointer(val)
    when :static
      instructions = pop_to_static(val)
    when :local, :argument, :this, :that
      instructions = pop_to_segment(seg_sym, val)
    end
    return instructions
  end

  def pop_to_temp(val)
    [
      '// Pop to temp',
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
    address = val.to_i.zero? ? 'THIS' : 'THAT'
    [
      '// Pop to pointer',
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{address}",
      'M=D'
    ]
  end

  def pop_to_static(val)
    [
      '// Pop to static',
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{@filename}.#{val}",
      'M=D'
    ]
  end

  def pop_to_segment(segment, val)
    if val == '0'
      instructions = [
        "// Pop to segment: #{segment}",
        "@#{SEGMENT_TABLE[segment]}",
        'D=M',
        '@13',
        'M=D',
        '@SP',
        'AM=M-1',
        'D=M',
        '@13',
        'A=M',
        'M=D'
      ]
    else
      instructions = [
        "// Pop to segment: #{segment}",
        "@#{SEGMENT_TABLE[segment]}",
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
    return instructions
  end
end

# rubocop:enable Metrics/MethodLength, Style/RedundantReturn
