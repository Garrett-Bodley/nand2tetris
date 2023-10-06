# frozen_string_literal: true

# A class to translate function call and return commands into Assembly
class VMFunctionTranslator
  attr_accessor :filename

  def initialize(filename)
    @filename = filename
    @return_count = 0
  end

  def return
    instructions = save_frame_to_r14
    instructions += save_return_addr_to_r15
    instructions += pop_to_arg
    instructions += sp_equals_arg_plus_one
    instructions += restore_that
    instructions += restore_this
    instructions += restore_arg
    instructions += restore_lcl
    instructions + goto_return_addr
  end

  def save_frame_to_r14
    %w[
      //\ Saving\ LCL\ to\ register\ 14!
      @LCL
      D=M
      @14
      M=D
    ]
  end

  def save_return_addr_to_r15
    %w[
      //\ Saving\ the\ return\ address!
      @LCL
      D=M
      @5
      A=D-A
      D=M
      @15
      M=D
    ]
  end

  def pop_to_arg
    %w[
      @ARG
      D=M
      @13
      M=D
      @SP
      AM=M-1
      D=M
      @13
      A=M
      M=D
    ]
  end

  def sp_equals_arg_plus_one
    %w[
      @ARG
      D=M+1
      @SP
      M=D
    ]
  end

  def restore_that
    %w[
      @14
      D=M
      @1
      A=D-A
      D=M
      @THAT
      M=D
    ]
  end

  def restore_this
    %w[
      @14
      D=M
      @2
      A=D-A
      D=M
      @THIS
      M=D
    ]
  end

  def restore_arg
    %w[
      @14
      D=M
      @3
      A=D-A
      D=M
      @ARG
      M=D
    ]
  end

  def restore_lcl
    %w[
      @14
      D=M
      @4
      A=D-A
      D=M
      @LCL
      M=D
    ]
  end

  def goto_return_addr
    %w[
      //\ Going\ To\ the\ Return\ Address!
      @15
      A=M
      0;JMP
    ]
  end

  def label(label)
    unless label.match(/^[a-zA-Z_:.][a-zA-Z0-9_:.]*$/)
      throw ArgumentError "Invalid label provided. A valid label is a string composed of any sequence of letters, digits, underscore (_), dot (.), and colon (:) that does not begin with a digit. (Received: #{label})" # rubocop:disable Layout/LineLength
    end
    [
      '// Label',
      "(#{@filename}.#{label})"
    ]
  end

  def goto(label)
    [
      '// goto',
      "@#{@filename}.#{label}",
      '0; JMP'
    ]
  end

  def if_goto(label)
    # if stack[stack.length - 1] != 0
    #   jump
    [
      '// if-goto',
      '@SP',
      'AM=M-1',
      'D=M',
      "@#{@filename}.#{label}",
      'D;JNE'
    ]
  end

  def declare_function(function_name, arg_count)
    instructions = label(function_name)
    count = 0
    while count < arg_count.to_i
      instructions += %w[
        @0
        D=A
        @SP
        AM=M+1
        A=A-1
        M=D
      ]
      count += 1
    end
    return instructions
  end

  def call(function_name, arg_count)
    return_label = make_return_label
    instructions = push_return(return_label)
    instructions += push_lcl
    instructions += push_arg
    instructions += push_this
    instructions += push_that
    instructions += set_arg(arg_count)
    instructions += set_lcl
    instructions += goto_function(function_name)
    instructions + inject_return_label(return_label)
  end

  def make_return_label
    label = "#{@filename}.RETURN.#{@return_count}"
    @return_count += 1
    label
  end

  def push_return(return_label)
    %W[
      //\ Pushing\ Return\ Address!
      @#{return_label}
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
  end

  def push_lcl
    %w[
      @LCL
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
  end

  def push_arg
    %w[
      @ARG
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
  end

  def push_this
    %w[
      @THIS
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
  end

  def push_that
    %w[
      @THAT
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    ]
  end

  def set_arg(arg_count) # rubocop:disable Naming/AccessorMethodName
    %W[
      @SP
      D=M
      @5
      D=D-A
      @#{arg_count}
      D=D-A
      @ARG
      M=D
    ]
  end

  def set_lcl
    %w[
      @SP
      D=M
      @LCL
      M=D
    ]
  end

  def goto_function(function_name)
    %W[
      @#{@filename}.#{function_name}
      0;JMP
    ]
  end

  def inject_return_label(return_label)
    %W[
      (#{return_label})
    ]
  end

end
