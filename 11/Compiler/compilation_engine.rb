# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
# frozen_string_literal: true

require_relative './symbol_table'
require_relative './vm_writer'

# Recursive Top-Down parser
class CompilationEngine
  SyntaxError = Class.new(StandardError)
  def initialize(output_path, tokenizer)
    @file = File.open(output_path, 'w+')
    @table = SymbolTable.new
    @writer = VMWriter.new(output_path.sub_ext('.vm'))
    @tokenizer = tokenizer
    @current_token = tokenizer.current_token

    @idx = 0
    @block = []
    @space_count = 0
  end

  def compile_class
    # 'class' className '{' classVarDec* subroutineDec* '}'
    open_structure_tag 'Class Declaration', '<class>'

    expect(@current_token.string == 'class')
    advance

    expect(@current_token.type == 'IDENTIFIER')
    @table.define(@current_token.string, 'className', :CLASSNAME)
    write_table_info_and_advance
    expect(@current_token.string == '{')
    advance

    compile_class_var_dec while @current_token.string.match?(/static|field/)

    compile_subroutine while @current_token.string.match?(/constructor|method|function/)

    expect(@current_token.string == '}')
    advance

    close_structure_tag '</class>'
  end

  def compile_class_var_dec
    # ('static' | 'field') type varName (',' varName)* ';'
    open_structure_tag 'Class Var Declaration', '<classVarDec>'

    #     the identifier category (var, argument, static, field, class, subroutine);
    #     ■ whether the identifier is presently being defined (e.g., the identifier stands for a variable declared in a
    #      var statement) or used (e.g., the identifier stands for a variable in an expression);
    #     ■ whether the identifier represents a variable of one of the four kinds (var, argument, static, field), and the
    #       running index assigned to the identifier by the symbol table.


    expect(@current_token.string.match?(/static|field/))
    kind = @current_token.string.upcase.to_sym
    advance

    expect(@current_token.type.match?(/IDENTIFIER|KEYWORD/))
    type = @current_token.string
    advance

    expect(@current_token.type == 'IDENTIFIER')
    name = @current_token.string
    @table.define(name, type, kind)
    write_table_info_and_advance

    while @current_token.string == ','
      advance
      expect(@current_token.type == 'IDENTIFIER')
      name = @current_token.string
      @table.define(name, type, kind)
      write_token_and_advance
    end

    expect(@current_token.string == ';')
    advance

    close_structure_tag '</classVarDec>'
  end

  def compile_subroutine
    # compiles a complete method, function, or constructor
    # ('constructor'|'function'|'method') ('void'|type) subroutineName '(' parameterList ')' subRoutineBody
    open_structure_tag 'Subroutine Declaration', '<subroutineDec>'

    @table.new_subroutine

    # Will have to compile constructor functions differently
    expect(@current_token.string.match?(/constructor|method|function/))
    write_token_and_advance

    expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
    return_type = @current_token.string
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    @table.func_name = @current_token.string
    write_token_and_advance

    expect(@current_token.string == '(')
    write_token_and_advance

    compile_param_list

    expect(@current_token.string == ')')
    write_token_and_advance

    compile_subroutine_body

    close_structure_tag '</subroutineDec>'
  end

  # def compile_constructor

  # end

  def compile_param_list
    # ((type varName)(',' type varName)*)?
    # compiles a possibly empty parameter list
    # not including the enclosing "()"
    open_structure_tag 'Parameter List', '<parameterList>'


    kind = :ARG
    unless @current_token.string == ')'
      expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
      type = @current_token.string
      advance

      expect(@current_token.type == 'IDENTIFIER')
      name = @current_token.string
      @table.define(name, type, kind)
      write_table_info_and_advance

      while @current_token.string == ','
        advance
        expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
        type = @current_token.string
        advance
        expect(@current_token.type == 'IDENTIFIER')
        name = @current_token.string
        @table.define(name, type, kind)
        write_table_info_and_advance
      end
    end

    close_structure_tag '</parameterList>'
  end

  def compile_subroutine_body
    # '{' varDec* statements '}'
    open_structure_tag 'Subroutine Body', '<subroutineBody>'

    expect(@current_token.string == '{')
    advance

    compile_var_dec while @current_token.string == 'var'

    @writer.write_function("#{@table.classname}.#{@table.func_name}", @table.var_count(:VAR))
    compile_statements

    expect(@current_token.string == '}')
    advance

    close_structure_tag '</subroutineBody>'
  end

  def compile_var_dec
    # compiles a var declaration
    # 'var' type varName (',' varName)* ';'
    open_structure_tag 'Var Declaration', '</varDec>'

    expect(@current_token.string == 'var')
    kind = :VAR
    advance

    # expect type
    expect(@current_token.string.match?(/void|int|char|boolean/) || @current_token.type == 'IDENTIFIER')
    type = @current_token.string
    advance

    expect(@current_token.type == 'IDENTIFIER')
    name = @current_token.string

    @table.define(name, type, kind)
    write_table_info_and_advance

    while @current_token.string == ','
      advance
      expect(@current_token.type == 'IDENTIFIER')
      name = @current_token.string
      @table.define(name, type, kind)
      write_table_info_and_advance
    end

    expect(@current_token.string == ';')
    advance

    close_structure_tag '</varDec>'
  end

  def compile_statements
    # compiles a sequence of statements, not including the enclosing "{}"
    # statement*
    open_structure_tag 'Statements', '<statements>'

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

    close_structure_tag '</statements>'
  end

  def compile_do
    # compiles a do statement
    # 'do' subroutineCall ';'
    open_structure_tag 'Do Statement', '<doStatement>'

    expect(@current_token.string == 'do')
    write_token_and_advance

    # compile subroutine call
    # test file wants you to write out empty expressionList tags for some reason
    # So I have to rewrite the same logic with one minor tweek
    #
    # if identifier()
    # assumed to be a method

    # if identifier()
    #   push current instance of class onto pointer (i think pointer?)
    #   push expressionList values
    #   call function

    # if identifier.subroutine()
    #   if table.has?(identifier) == true
    #     push identifier val onto stack
    #     push top stack value into pointer (i think?)
    #     compile expressionList
    #     call function
    #   else (isAClassFunction)
    #     compile expressionList
    #     call function

    expect(@current_token.type == 'IDENTIFIER')
    binding.pry
    identifier = @current_token.string

    if tokenizer.peek.string != '.'
      # method call of current class
    end

    # if method
    # push class instance base address onto stack
    # push local 0

    is_method = @table.has?(identifier)
    if is_method

    end
    write_token_and_advance

    expect(@current_token.string.match?(/\(|\./))

    if @current_token.string == '.'
      # if identifier.subroutine()
      # find identifier in table. Subroutine is a method of that identifier.
      #   we must set pointer 0 to the instance's base address
      # if no entry in table, assumed to be a Class function
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      subroutine_name = @current_token.string
      write_token_and_advance
      func_name = "#{identifier}.#{subroutine_name}"
      # i need to know how many arguments are being passed to the subroutine call
      # call func_name n_args
    end

    expect(@current_token.string == '(')
    write_token_and_advance
    # needs to return n_args
    n_args = compile_expression_list

    expect(@current_token.string == ')')
    write_token_and_advance
    binding.pry
    if is_method
      kind = @table.kind?(identifier)
      index = @table.index?(identifier)

      @writer.write_call(func_name, n_args)

    end

    # end subroutine call

    # discard return value
    @writer.write_pop('temp', 0)
    expect(@current_token.string == ';')
    write_token_and_advance

    close_structure_tag '</doStatement>'
  end

  def compile_subroutine_call
    # subroutineName '(' expressionList ')' |
    # (className|varName) '.' subroutineName '(' expressionList ')'
    expect(@current_token.type == 'IDENTIFIER')
    subroutine_name = @current_token.string
    write_token_and_advance

    expect(@current_token.string.match?(/\(|\./))

    if @current_token.string == '.'
      write_token_and_advance

      expect(@current_token.type == 'IDENTIFIER')
      subroutine_name += ".#{current_token.string}"
      write_token_and_advance
    end

    expect(@current_token.string == '(')
    write_token_and_advance
    n_args = compile_expression_list

    expect(@current_token.string == ')')
    write_token_and_advance
    @writer.write_call(subroutine_name, n_args)
  end

  def compile_let
    # compiles a let statement
    # 'let' varName('[' expression ']')? '=' expression ';'
    open_structure_tag 'Let Statement', '<letStatement>'

    expect(@current_token.string == 'let')
    write_token_and_advance

    expect(@current_token.type == 'IDENTIFIER')
    write_table_info_and_advance

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

    close_structure_tag '</letStatement>'
  end

  def compile_while
    # 'while' '(' expression ')' '{' statements '}'
    open_structure_tag('While Statement', '<whileStatement>')
    # compiles a while statement
    expect(@current_token.string == 'while')
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

    close_structure_tag('</whileStatement>')
  end

  def compile_return
    # 'return' expression? ';'
    open_structure_tag('Return Statement', '<returnStatement>')
    # compiles a return statement
    expect(@current_token.string == 'return')
    write_token_and_advance
    if @current_token.string != ';'
      compile_expression
    else
      @writer.write_push('constant', 0)
    end
    expect(@current_token.string == ';')
    write_token_and_advance
    @writer.write_return

    close_structure_tag('</returnStatement>')
  end

  def compile_if
    # 'if' '(' expression ')' '{' statements '}' ('else' '{' statements '}')?
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

    # else{}
    write_token_and_advance
    expect(@current_token.string == '{')
    write_token_and_advance
    compile_statements
    expect(@current_token.string == '}')
    write_token_and_advance

    close_structure_tag('</ifStatement>')
  end

  def compile_term # rubocop:disable Metrics/CyclomaticComplexity
    # term (op term)*
    # compiles a "term". This routine is faced with a slight difficulty when trying to decide between some of the
    # alternative parsing rules.

    # Specifically, if the current token is an identifier, the routine must distinguish between a variable,
    # an array entry, and a subroutine call

    # A single look-ahead token, which may be one of "[" "(" or "." suffices to distinguish between the
    # three possibilities

    # Any other token is not part of this term and should not be advanced over
    open_structure_tag 'Term', '<term>'

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
        compile_unary_op_term
      end
    when 'KEYWORD'
      expect(@current_token.string.match?(/true|false|this|null/))
      compile_keyword_term
    end

    close_structure_tag '</term>'
  end

  def compile_keyword_term
    # 'true' | 'false' | 'null' | 'this'
    expect(@current_token.type == 'KEYWORD')
    write_token_and_advance
  end

  def compile_int_const
    expect(@current_token.type == 'INT_CONST')
    @writer.write_push('constant', @current_token.string)
    write_token_and_advance
  end

  def compile_string_const
    expect(@current_token.type == 'STRING_CONST')
    write_token_and_advance
  end

  def compile_unary_op_term
    # unaryOp term
    expect(@current_token.string.match?(/-|~/))
    op = @current_token.string
    write_token_and_advance
    compile_term
    @writer.write_arithmetic('not') if op == '~'
    @writer.write_arithmetic('neg') if op == '-'
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
      write_table_info_and_advance
    end
  end

  def compile_array_entry
    # varName '[' expression ']'
    expect(@current_token.type == 'IDENTIFIER')
    write_table_info_and_advance

    expect(@current_token.string == '[')
    write_token_and_advance

    compile_term

    expect(@current_token.string == ']')
    write_token_and_advance
  end

  def compile_expression_list
    # (expression (',' expression)*)?
    # compiles a (possibly empty) comma-separated list of expressions
    open_structure_tag 'Expression List', '<expressionList>'
    n_args = 0
    if @current_token.string != ')'
      compile_expression
      n_args += 1
      while @current_token.string == ','
        write_token_and_advance
        compile_expression
        n_args += 1
      end
    end

    close_structure_tag('</expressionList>')
    n_args
  end

  def compile_expression # rubocop:disable Metrics/CyclomaticComplexity
    # term (op term)*
    open_structure_tag 'Expression', '<expression>'

    compile_term
    while @current_token.string.match?(%r{\+|-|\*|/|&|\||<|>|=})
      op = @current_token.string
      write_token_and_advance
      compile_term
      case op
      when '+'
        @writer.write_arithmetic('add')
      when '-'
        @writer.write_arithmetic('sub')
      when '*'
        @writer.write_call('Math.multiply', 2)
      when '/'
        @writer.write_call('Math.divide', 2)
      when '&'
        @writer.write_arithmetic('and')
      when '|'
        @writer.write_arithmetic('or')
      when '<'
        @writer.write_arithmetic('lt')
      when '>'
        @writer.write_arithmetic('gt')
      when '='
        @writer.write_arithmetic('eq')
      end
    end

    close_structure_tag '</expression>'
  end

  def expect(boolean)
    syntax_error(@block.last, @current_token) unless boolean
  end

  def syntax_error(block, token)
    source_filename = Pathname.new(File.basename(@file)).sub_ext('.jack')
    raise SyntaxError, "Unexpected '#{token.string}' in #{block} on line #{token.line_num} in #{source_filename}"
  end

  def write_string(string)
    @file.puts ' ' * @space_count + string
  end

  def write_token_and_advance
    write_string(@current_token.to_s)
    advance
  end

  def write_table_info_and_advance
    name = @current_token.string
    type = @table.type?(name)
    kind = @table.kind?(name)
    index = @table.index?(name)
    tag_string = [kind.to_s.downcase, type.capitalize, index].join
    write_string "<#{tag_string}> #{name} </#{tag_string}>"
    advance
  end

  def advance
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
