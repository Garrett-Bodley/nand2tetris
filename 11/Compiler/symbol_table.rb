# frozen_string_literal: true

require_relative 'symbol'

# Symbol Table for each frame of code in Jack
class SymbolTable

  def initialize
    @static = []
    @field = []
    @arg = []
    @
    @index = 0
    @class_hash = {}
    @subroutine_hash = {}
    var = []
  end

  def define(name, type, kind)
    table << Symbol.new(name, type, kind, @index)
  end

  def var_count(type)
    @table.select { |el| el.type == type }.count
  end

  def kind?(name)
    table.select { |el| el.name == name }[0].kind
  end

  def type?(name)
    table.select { |el| el.name == name }[0].kind
  end

  def index?(name)
    table.select { |el| el.name == name }[0].index
  end
end

# Main.vm
#
# pop static 4


subroutine_dictionary

class_dictionary
