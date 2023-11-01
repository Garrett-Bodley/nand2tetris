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
    @string
  end
end
