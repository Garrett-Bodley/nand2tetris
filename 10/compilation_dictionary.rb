# frozen_string_literal: true

# A dictionary for variable and subroutines found during the compilation process
class CompilationDictionary
  attr_accessor :vars, :subroutines

  def initialize
    @vars = {}
    @subroutines = {}
  end

  def add_var(string, type)
    @vars[string] = type
  end

  def add_subroutine(string, type)
    @subroutines[string] = type
  end

  def var?(string)
    @vars[string] != nil
  end

  def subroutine?(string)
    @subroutines[string] != nil
  end

  def var_type(string)
    @vars[string]
  end

  def subroutine_type(string)
    @subroutines[string]
  end
end
