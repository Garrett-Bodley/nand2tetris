# rubocop:disable Style/ConditionalAssignment
# frozen_string_literal: true

# Represents a Token
class Token
  attr_reader :type, :line_num, :string

  def initialize(type, string, line_num)
    @type = type
    @string = string
    @line_num = line_num
  end

  def to_s # rubocop:disable Metrics/MethodLength
    case @type
    when 'INT_CONST'
      type_string = 'integerConstant'
    when 'STRING_CONST'
      type_string = 'stringConstant'
    else
      type_string = @type.downcase
    end

    case @string
    when '<'
      content = '&lt;'
    when '>'
      content = '&gt;'
    when '&'
      content = '&amp;'
    else
      content = @string
    end

    "<#{type_string}> #{content} </#{type_string}>"
  end
end

# rubocop:enable Style/ConditionalAssignment
