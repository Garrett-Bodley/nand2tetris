# rubocop:disable Metrics/AbcSize
# frozen_string_literal: true

require_relative './compilation_dictionary'

# Recursive Top-Down parser
class CompilationEngine
  SyntaxError = Class.new(StandardError)
  def initialize(output_path, tokenizer)
    @file = File.open(output_path, 'w+')
    @dict = CompilationDictionary.new
    @tokenizer = tokenizer
    @current_token = tokenizer.current_token
    @idx = 0
    @block = []
    @space_count = 0
  end

  def compile_class
    @block.push('Class Declaration')
    write_string('<class>')
    @space_count += 2

    expect(@current_token.string == 'class')
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.string == '{')
    write_token_and_advance

    compile_class_var_dec while @current_token.string.match?(/static|field/)

    compile_subroutine while @current_token.string.match?(/constructor|method|function/)
    @space_count -= 2
    write_string('</class>')
    @block.pop
  end

  def compile_class_var_dec
    # ('static' | 'field') type varName (',' varName)* ';'
    @block.push('Class Var Declaration')
    write_string('<classVarDec>')

    @space_count += 2

    expect(@current_token.string.match?(/static|field/))
    write_token_and_advance

    expect(@current_token.type.match?(/IDENTIFIER|KEYWORD/))
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    while @current_token.string == ','
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      write_token_and_advance
    end

    expect(@current_token.string == ';')
    write_token_and_advance

    @space_count -= 2
    write_string('</classVarDec>')
    @block.pop
  end

  def compile_subroutine
    # compiles a complete method, function, or constructor
    # ('constructor'|'function'|'method') ('void'|type) subroutineName '(' parameterList ')' subRoutineBody
    @block.push('Subroutine Declaration')
    write_string('<subroutineDec>')
    @space_count += 2

    expect(@current_token.string.match?(/constructor|method|function/))
    write_token_and_advance

    expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.string == '(')
    write_token_and_advance

    compile_param_list

    expect(@current_token.string == ')')

  end

  def compile_param_list
    # compiles a possibly empty parameter list
    # not including the enclosing "()"
    @block.push('Parameter List')
    write_string('<parameterList>')
    @space_count += 2
    expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    while @current_token.string == ','
      write_token_and_advance
      expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      write_token_and_advance
    end
    expect(@current_token.string == ')')
    @space_count -= 2
    write_string('</parameterList>')
    @block.pop
  end

  def compile_var_dec
    # compiles a var declaration
  end

  def compile_subroutine_body
    # '{' varDec* statements '}'

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

  def expect(boolean)
    syntax_error(@block.last, @current_token) unless boolean
  end

  def syntax_error(block, token)
    raise SyntaxError, "Unexpected '#{token.string}' in #{block} on line #{token.line_num}"
  end

  def write_string(string)
    @file.puts ' ' * @space_count + string
  end

  def write_token_and_advance
    write_string(@current_token.to_s)
    @current_token = @tokenizer.advance
  end

end

# rubocop:enable Metrics/AbcSize
