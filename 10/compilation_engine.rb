# frozen_string_literal: true

# Recursive Top-Down parser
class CompilationEngine
  def initialize(filepath)
    @filepath = filepath
  end

  def compile_class
    # compiles a complete class
  end

  def compile_class_var_dec
    # compiles a static declaration or a field declaration
  end

  def compile_subroutine
    # compiles a complete method, function, or constructor
  end

  def compile_param_list
    # compiles a possibly empty parameter list
    # not including the enclosing "()"
  end

  def compile_var_dec
    # compiles a var declaration
  end

  def compile_statements
    # compiles a sequence of statements, not including the enclosing "{}"
  end

  def compile_do
    # compiles a do statement
  end

  def compile_let
    # compiles a let statement
  end

  def compile_while
    # compiles a while statement
  end

  def compile_return
    # compiles a return statement
  end

  def compile_if
    # compiles an if statement, possible with a a trailing else clause
  end

  def compile_term
    # compiles a "term". This routine is faced with a slight difficulty when trying to decide between some of the
    # alternative parsing rules.

    # Specifically, if the current token is an identifier, the routine must distinguish between a variable,
    # an array entry, and a subroutine call

    # A single look-ahead token, which may be one of "[" "{" "(" or "." suffices to distinguish between the
    # three possibilities

    # Any other token is not part of this term and should not be advanced over
  end

  def compile_expression_list
    # compiles a (possibly empty) comma-separated list of expressions
  end

end
