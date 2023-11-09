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

  def to_s(table) # rubocop:disable Metrics/MethodLength
    case @type
    when 'INT_CONST'
      type_string = 'integerConstant'
    when 'STRING_CONST'
      type_string = 'stringConstant'
    when 'IDENTIFIER'
      kind = table.kind?(@string)
      type = table.type?(@string)
      index = table.index?(@string)
      tag_string = [kind.to_s.downcase, type.capitalize, index].join
      # <kind type index> content </kind type index>
      return "<#{tag_string}> #{@string} </#{tag_string}>"
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
