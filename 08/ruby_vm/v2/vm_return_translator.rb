# frozen_string_literal: true

class VMReturnTranslator
  def return

  end

  def save_frame_and_return_address
    [
      '@LCL',
      'D=M',
      '@13',
      'M=D', # ROM[13] == frame
      '@5',
      'D=D-A', # D = frame - 5
      '@14',
      'M=D' # ROM[14] = returnAddress
    ]
  end

  def pop_arg
    
  end
end
