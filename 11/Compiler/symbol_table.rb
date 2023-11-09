# frozen_string_literal: true

# Symbol Table for each frame of code in Jack
class SymbolTable
  SyntaxError = Class.new(StandardError)
  Symbol = Struct.new(:name, :type)
  attr_accessor :dict

  def initialize
    # @dict = Dict.new(KlassDict.new([], []), SubroutineDict.new([], []))
    # @subroutine = []
    # @klass = []
    @static_idx = 0
    @dict = {
      CLASSNAME: {},
      STATIC: {},
      FIELD: {},
      ARG: {},
      VAR: {}
    }
  end

  def define(name, type, kind)
    raise SyntaxError, "Variable name cannot match name of class. (Received: #{name})" if name == @dict[:CLASSNAME]

    unless %i[STATIC FIELD ARG VAR CLASSNAME].include?(kind)
      raise SyntaxError,
            "Invalid kind provided to Symbol Table (Expected one of: STATIC, FIELD, ARG, VAR. Received: #{kind})"
    end

    return @dict[:CLASSNAME][name] = Symbol.new(name, type) if kind == :CLASSNAME

    @dict.each_value do |kind_dict|
      raise SyntaxError, "Variable with name '#{name}' was previously defined" unless kind_dict[name].nil?
    end
    @dict[kind][name] = Symbol.new(name, type)
  end

  def var_count(kind)
    unless %i[STATIC FIELD ARG VAR].include?(kind)
      raise SyntaxError,
            "Invalid kind provided to Symbol Table (Expected one of: STATIC, FIELD, ARG, VAR. Received: #{kind})"
    end

    @dict[kind].count
  end

  def kind?(name)
    @dict.each do |kind, kind_dict|
      return kind if kind_dict[name]
    end
    raise SyntaxError, "Provided Identifier name not previously defined in SymbolTable (Received: #{name})"
  end

  def type?(name)
    @dict.each_value do |kind_dict|
      return kind_dict[name].type if kind_dict[name]
    end
    raise SyntaxError, "Provided Identifier name not previously defined in SymbolTable (Received: #{name})"
  end

  def index?(name)
    @dict.each_value do |kind_dict|
      return kind_dict.keys.find_index(name) if kind_dict[name]
    end
    raise SyntaxError, "Provided Identifier name not previously defined in SymbolTable (Received: #{name})"
  end

  def new_subroutine
    @dict[:ARG] = {}
    @dict[:VAR] = {}
  end

  def new_class
    @dict[:CLASSNAME] = {}
    @dict[:FIELD] = {}
    @dict[:STATIC] = {}
  end
end
