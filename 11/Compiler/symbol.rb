# frozen_string_literal: true

# Represents a symbol in the compiler's symbol table
class Symbol
  attr_accessor :name, :type, :kind

  def initialize(name, type, kind, index)
    @name = name
    @type = type
    @kind = kind
    @index = index
  end
end
