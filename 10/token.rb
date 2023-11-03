# frozen_string_literal: true

# Represents a Token
class Token
  attr_reader :type, :line_num, :string

  def initialize(type, string, line_num)
    @type = type
    @string = string
    @line_num = line_num
  end

  def to_s
    case @type
    when 'INT_CONST'
      type_string = 'integerConstant'
    when 'STRING_CONST'
      type_string = 'stringConstant'
    else
      type_string = @type.downcase
    end
    "<#{type_string}> #{string} </#{type_string}>"
  end
end
