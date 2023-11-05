# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
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

    expect(@current_token.string == '}')
    write_token_and_advance

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
    write_token_and_advance

    compile_subroutine_body

    @space_count -= 2
    write_string('</subroutineDec>')
    @block.push('Subroutine Declaration')

  end

  def compile_param_list
    # compiles a possibly empty parameter list
    # not including the enclosing "()"
    @block.push('Parameter List')
    write_string('<parameterList>')
    @space_count += 2

    unless @current_token.string == ')'
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
    end

    @space_count -= 2
    write_string('</parameterList>')
    @block.pop
  end

  def compile_subroutine_body
    # '{' varDec* statements '}'
    @block.push('Subroutine Body')
    write_string('<subroutineBody>')
    @space_count += 2

    expect(@current_token.string == '{')
    write_token_and_advance

    compile_var_dec while @current_token.string == 'var'

    compile_statements

    expect(@current_token.string == '}')
    write_token_and_advance

    @space_count -= 2
    write_string('</subroutineBody>')
    @block.pop
  end

  def compile_var_dec
    # compiles a var declaration
    # 'var' type varName (',' varName)* ';'
    @block.push('Var Declaration')
    write_string('<varDec>')
    @space_count += 2

    expect(@current_token.string == 'var')
    write_token_and_advance

    # expect type
    expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
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
    write_string('</varDec>')
    @block.pop
  end

  def compile_statements
    # compiles a sequence of statements, not including the enclosing "{}"
    # binding.pry

    @block.push('Statements')
    write_string('<statements>')
    @space_count += 2


    while @current_token.string != '}'
      case @current_token.string
      when 'do'
        compile_do
      when 'let'
        compile_let
      when 'while'
        compile_while
      when 'if'
        compile_if
      when 'return'
        compile_return
      end
    end

    @space_count -= 2
    write_string('</statements>')
    @block.pop
  end

  def compile_do
    # compiles a do statement
    # binding.pry
    @block.push('Do Statement')
    write_string('<doStatement>')
    @space_count += 2

    expect(@current_token.string == 'do')
    write_token_and_advance

    # compile subroutine call
    # test file wants you to write out empty expressionList tags for some reason
    # So I have to rewrite the same logic with one minor tweek
    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.string.match?(/\(|\./))

    if @current_token.string == '.'
      write_token_and_advance

      expect(@current_token.type == 'IDENTIFIER')
      write_token_and_advance
    end

    expect(@current_token.string == '(')
    write_token_and_advance

    compile_expression_list

    expect(@current_token.string == ')')
    write_token_and_advance

    # end subroutine call

    expect(@current_token.string == ';')
    write_token_and_advance

    @space_count -= 2
    write_string('</doStatement>')
    @block.pop
  end

  def compile_subroutine_call
    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.string.match?(/\(|\./))

    if @current_token.string == '.'
      write_token_and_advance

      expect(@current_token.type == 'IDENTIFIER')
      write_token_and_advance
    end

    expect(@current_token.string == '(')
    write_token_and_advance

    compile_expression_list if @current_token.string != ')'

    expect(@current_token.string == ')')
    write_token_and_advance
  end

  def compile_let
    # compiles a let statement
    @block.push('Let Statement')
    write_string('<letStatement>')
    @space_count += 2

    expect(@current_token.string == 'let')
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    if @current_token.string == '['
      write_token_and_advance
      compile_term
      expect(@current_token.string == ']')
      write_token_and_advance
    end

    expect(@current_token.string == '=')
    write_token_and_advance

    compile_expression

    expect(@current_token.string == ';')
    write_token_and_advance

    @space_count -= 2
    write_string('</letStatement>')
    @block.pop
  end

  def compile_while
    open_structure_tag('While Statement', '<whileStatement>')
    # compiles a while statement
    expect(@current_token.string == 'while')
    write_token_and_advance

    expect(@current_token.string == '(')
    compile_expression
    expect(@current_token.string == ')')
    write_token_and_advance
    expect(@current_token.string == '{')
    compile_statements
    expect(@current_token.string == '}')
    write_token_and_advance

    close_structure_tag('</whileStatement>')
  end

  def compile_return
    open_structure_tag('Return Statement', '<returnStatement>')
    # compiles a return statement
    expect(@current_token.string == 'return')
    write_token_and_advance
    compile_expression if(@current_token.string != ';')
    expect(@current_token.string == ';')
    write_token_and_advance

    close_structure_tag('</returnStatement>')
  end

  def compile_if
    # compiles an if statement, possible with a a trailing else clause
    open_structure_tag('If Statement', '<ifStatement>')


    expect(@current_token.string == 'if')
    write_token_and_advance

    expect(@current_token.string == '(')
    write_token_and_advance
    compile_expression
    expect(@current_token.string == ')')
    write_token_and_advance

    expect(@current_token.string == '{')
    write_token_and_advance
    compile_statements
    expect(@current_token.string == '}')
    write_token_and_advance

    close_structure_tag('</ifStatement>') && return unless @current_token.string == 'else'

    write_token_and_advance
    expect(@current_token.string == '{')
    write_token_and_advance
    compile_statements
    expect(@current_token.string == '}')
    write_token_and_advance

    close_structure_tag('</ifStatement>')
  end

  def compile_term
    # compiles a "term". This routine is faced with a slight difficulty when trying to decide between some of the
    # alternative parsing rules.

    # Specifically, if the current token is an identifier, the routine must distinguish between a variable,
    # an array entry, and a subroutine call

    # A single look-ahead token, which may be one of "[" "(" or "." suffices to distinguish between the
    # three possibilities

    # Any other token is not part of this term and should not be advanced over
    @block.push('Term')
    write_string '<term>'
    @space_count += 2

    case @current_token.type
    when 'IDENTIFIER'
      compile_identifier_term
    when 'INT_CONST'
      compile_int_const
    when 'STRING_CONST'
      compile_string_const
    when 'SYMBOL'
      case @current_token.string
      when '('
        compile_paren_term
      when /-|~/
        compile_unary_op
      end
    when 'KEYWORD'
      expect(@current_token.string.match?(/true|false|this|null/))
      compile_keyword_term
    end

    @space_count -= 2
    write_string '</term>'
    @block.pop
  end

  def compile_keyword_term
    expect(@current_token.type == 'KEYWORD')
    write_token_and_advance
  end

  def compile_int_const
    expect(@current_token.type == 'INT_CONST')
    write_token_and_advance
  end

  def compile_string_const
    expect(@current_token.type == 'STRING_CONST')
    write_token_and_advance
  end

  def compile_unary_op
    expect(@current_token.string.match?(/-|~/))
    write_token_and_advance
  end

  def compile_paren_term
    # '(' expression ')'
    expect(@current_token.string == '(')
    write_token_and_advance
    compile_expression
    expect(@current_token.string == ')')
    write_token_and_advance
  end

  def compile_identifier_term
    case @tokenizer.peek.string
    when '['
      compile_array_entry
    when /\(|\./
      compile_subroutine_call
    else
      expect(@current_token.type == 'IDENTIFIER')
      write_token_and_advance
    end
  end

  def compile_array_entry
    # array[expression]
    expect(@current_token.type == 'IDENTIFIER')
    write_token_and_advance

    expect(@current_token.string == '[')
    write_token_and_advance

    compile_term

    expect(@current_token.string == ']')
    write_token_and_advance
  end

  def compile_expression_list
    # compiles a (possibly empty) comma-separated list of expressions
    open_structure_tag('Expression List', '<expressionList>')

    if @current_token.string != ')'
      compile_expression
      while @current_token.string == ','
        write_token_and_advance
        compile_expression
      end
    end

    close_structure_tag('</expressionList>')
  end

  def compile_expression
    @block.push('Expression')
    write_string('<expression>')
    @space_count += 2

    compile_term
    while @current_token.string.match?(%r{\+|-|\*|/|&|\||<|>|=})
      write_token_and_advance
      compile_term
    end

    @space_count -= 2
    write_string('</expression>')
    @block.pop
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

  def open_structure_tag(block, tag)
    @block.push block
    write_string tag
    @space_count += 2
  end

  def close_structure_tag(tag)
    @space_count -= 2
    write_string tag
    @block.pop
  end

end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
