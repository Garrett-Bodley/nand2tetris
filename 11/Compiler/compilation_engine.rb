# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
# frozen_string_literal: true

require_relative './symbol_table'
require_relative './vm_writer'

# Recursive Top-Down parser
class CompilationEngine
  WHILE_EXP = 'WHILE_EXP'
  WHILE_END = 'WHILE_END'
  IF_TRUE = 'IF_TRUE'
  IF_FALSE = 'IF_FALSE'
  IF_END = 'IF_END'
  SyntaxError = Class.new(StandardError)
  def initialize(output_path, tokenizer)
    @file = File.open(output_path, 'w+')
    @table = SymbolTable.new
    @writer = VMWriter.new(output_path.sub_ext('.vm'))
    @tokenizer = tokenizer
    @current_token = tokenizer.current_token

    @if_idx = 0
    @while_idx = 0

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
    @table.classname = @current_token.string
    write_token_and_advance
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
    @table.subroutine_type = @current_token.string
    write_token_and_advance
    # if @current_token.string == 'constructor'
    #   field_count = @table.var_count(:FIELD)
    #   @writer.write_push('constant', field_count)
    #   @writer.write_call('Memory.alloc', field_count)
    # elsif @current_token.string == 'method'

    # end
    # # case @current_token.string
    # when 'constructor'
    #   compile_constructor
    # when 'method'
    #   compile_method
    # when 'function'
    #   compile_function
    # end

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

  def compile_constructor
    # 'constructor' className 'new' '(' parameterList ')' subRoutineBody
    expect(@current_token.string == 'constructor')
    write_token_and_advance
    expect(@current_token.string == @table.classname)
    return_type = @current_token.string
    write_token_and_advance
    expect(@current_token.string == 'new')
    write_token_and_advance
    expect(@current_token.string == '(')
    write_token_and_advance
    compile_param_list
    expect(@current_token.string == ')')
    compile_constructor_body
  end

  # def compile_constructor_body
  #   # '{' varDec* statements '}'
  #   open_structure_tag 'Subroutine Body', '<subroutineBody>'

  #   expect(@current_token.string == '{')
  #   advance

  #   compile_var_dec while @current_token.string == 'var'

  #   @writer.write_function("#{@table.classname}.#{@table.func_name}", @table.var_count(:VAR))
  #   compile_statements

  #   expect(@current_token.string == '}')
  #   advance

  #   clos
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
    case @table.subroutine_type
    when 'constructor'
      field_count = @table.var_count(:FIELD)
      @writer.write_push('constant', field_count)
      @writer.write_call('Memory.alloc', 1)
      @writer.write_pop('pointer', 0)
    when 'method'
      @writer.write_push('argument', 0)
      @writer.write_pop('pointer', 0)
    end

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
        # I wish @while_idx++ was valid ruby 🙁
        temp = @while_idx
        @while_idx += 1
        compile_while(temp)
      when 'if'
        temp = @if_idx
        @if_idx += 1
        compile_if(temp)
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

    compile_subroutine_call
    # # compile subroutine call
    # # test file wants you to write out empty expressionList tags for some reason
    # # So I have to rewrite the same logic with one minor tweek
    # #
    # # if identifier()
    # # assumed to be a method

    # # if identifier()
    # #   push current instance of class onto pointer (i think pointer?)
    # #   push expressionList values
    # #   call function

    # # if identifier.subroutine()
    # #   if table.has?(identifier) == true
    # #     push identifier val onto stack
    # #     push top stack value into pointer (i think?)
    # #     compile expressionList
    # #     call function
    # #   else (isAClassFunction)
    # #     compile expressionList
    # #     call function

    # expect(@current_token.type == 'IDENTIFIER')
    # identifier = @current_token.string

    # # maybe do this? Gotta figure this logic out
    # # write_token_and_advance

    # expect(@current_token.string.match?(/\(|\./))
    # if @current_token.string == '('
    #   # doSomething()
    #   # method call of current class instance
    #   @writer.write_push('pointer', 0)
    # elsif @current_token.string == '.'
    #   write_token_and_advance
    #   if @table.has?(identifier)
    #     # varName.doSomething()
    #     kind = @table.kind(identifier)
    #     segment = parse_segment(kind)
    #     index = @table.index?(identifier)
    #     @writer.write_push(segment, index)
    #   elsif identifier == 'this'
    #     # this.doSomething()
    #     @writer.write_push('pointer', 0)
    #   end
    # end

    # # METHOD CALL
    # # this.doSomething()
    # # varName.doSomething()
    # #
    # # FUNCTION CALL
    # # ClassName.doSomething()

    # # if method
    # # push class instance base address onto stack
    # # push local 0
    # write_token_and_advance

    # expect(@current_token.string.match?(/\(|\./))

    # if @current_token.string == '.'
    #   # if identifier.subroutine()
    #   # find identifier in table. Subroutine is a method of that identifier.
    #   #   we must set pointer 0 to the instance's base address
    #   # if no entry in table, assumed to be a Class function
    #   write_token_and_advance
    #   expect(@current_token.type == 'IDENTIFIER')
    #   subroutine_name = @current_token.string
    #   write_token_and_advance
    #   func_name = "#{identifier}.#{subroutine_name}"
    #   # i need to know how many arguments are being passed to the subroutine call
    #   # call func_name n_args
    # end

    # expect(@current_token.string == '(')
    # write_token_and_advance
    # # needs to return n_args
    # n_args = compile_expression_list

    # expect(@current_token.string == ')')
    # write_token_and_advance
    # binding.pry
    # if is_method
    #   kind = @table.kind?(identifier)
    #   index = @table.index?(identifier)

    #   @writer.write_call(func_name, n_args)

    # end

    # end subroutine call

    # discard return value
    @writer.write_pop('temp', 0)
    expect(@current_token.string == ';')
    write_token_and_advance

    close_structure_tag '</doStatement>'
  end

  def compile_subroutine_call

    # compile subroutine call
    #
    # METHOD CALL
    # this.doSomething(x, y)
    # varName.doSomething(x, y)
    # doSomething(x, y)
    #
    # FUNCTION CALL
    # ClassName.doSomething(x, y)
    #
    # doSomething(x, y)
    #   push pointer 0
    #   push x
    #   push y
    #   call ClassName.doSomething n_args + 1
    #
    # this.doSomething(x, y)
    #   push pointer 0
    #   push x
    #   push y
    #   call ClassName.doSomething n_args + 1
    #
    # varName.doSomething(x, y)
    #   segment = parse_segment(@table.kind?(varName))
    #   index = @table.index?(varName)
    #
    #   push segment index
    #   push x
    #   push y
    #   call ClassName.doSomething n_args + 1
    #
    # ClassName.doSomething(x, y)
    #   push x
    #   push y
    #   call ClassName.doSomething n_args

    expect(@current_token.type == 'IDENTIFIER')

    if @current_token.string == 'this'
      # this.doSomething(x, y)
      @writer.write_push('pointer', 0)
      write_token_and_advance
      expect(@current_token.string == '.')
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      func_name = @current_token.string
      classname = @table.classname
      write_token_and_advance
      expect(@current_token.string == '(')
      write_token_and_advance
      n_args = compile_expression_list
      expect(@current_token.string == ')')
      write_token_and_advance
      @writer.write_call("#{classname}.#{func_name}", n_args + 1)
    elsif @tokenizer.peek.string == '('
      # doSomething(x, y)
      @writer.write_push('pointer', 0)
      func_name = @current_token.string
      classname = @table.classname
      write_token_and_advance
      expect(@current_token.string == '(')
      write_token_and_advance
      n_args = compile_expression_list
      expect(@current_token.string == ')')
      write_token_and_advance
      expect(@current_token.string == ';')
      @writer.write_call("#{classname}.#{func_name}", n_args + 1)
    elsif @table.has?(@current_token.string) && @tokenizer.peek.string == '.'
      # varName.doSomething(x, y)
      classname = @table.type?(@current_token.string)
      segment = parse_segment(@table.kind?(@current_token.string))
      index = @table.index?(@current_token.string)
      @writer.write_push(segment, index)
      write_token_and_advance
      expect(@current_token.string == '.')
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      func_name = @current_token.string
      write_token_and_advance
      expect(@current_token.string == '(')
      write_token_and_advance
      n_args = compile_expression_list
      expect(@current_token.string == ')')
      write_token_and_advance
      @writer.write_call("#{classname}.#{func_name}", n_args + 1)
    elsif @tokenizer.peek.string == '.'
      # ClassName.doSomething(x, y)
      classname = @current_token.string
      write_token_and_advance
      expect(@current_token.string == '.')
      write_token_and_advance
      expect(@current_token.type == 'IDENTIFIER')
      func_name = @current_token.string
      write_token_and_advance
      expect(@current_token.string == '(')
      write_token_and_advance
      n_args = compile_expression_list
      expect(@current_token.string == ')')
      write_token_and_advance
      @writer.write_call("#{classname}.#{func_name}", n_args)
    end

    # maybe do this? Gotta figure this logic out
    # write_token_and_advance



    # # OLD CODE
    # # subroutineName '(' expressionList ')' |
    # # (className|varName) '.' subroutineName '(' expressionList ')'
    # expect(@current_token.type == 'IDENTIFIER')
    # subroutine_name = @current_token.string
    # write_token_and_advance

    # expect(@current_token.string.match?(/\(|\./))

    # if @current_token.string == '.'
    #   write_token_and_advance

    #   expect(@current_token.type == 'IDENTIFIER')
    #   subroutine_name += ".#{current_token.string}"
    #   write_token_and_advance
    # end

    # expect(@current_token.string == '(')
    # write_token_and_advance
    # n_args = compile_expression_list

    # expect(@current_token.string == ')')
    # write_token_and_advance
    # @writer.write_call(subroutine_name, n_args)
  end

  def compile_let
    # compiles a let statement
    # 'let' varName('[' expression ']')? '=' expression ';'
    open_structure_tag 'Let Statement', '<letStatement>'

    expect(@current_token.string == 'let')
    write_token_and_advance

    is_array = false
    expect(@current_token.type == 'IDENTIFIER' && @table.has?(@current_token.string))
    kind = @table.kind?(@current_token.string)
    segment = parse_segment(kind)
    index = @table.index?(@current_token.string)

    write_table_info_and_advance

    if @current_token.string == '['
      is_array = true
      write_token_and_advance
      compile_expression
      expect(@current_token.string == ']')
      @writer.write_push(segment, index)
      @writer.write_arithmetic('add')
      # DO NOT SET POINTER 1 TO THE COMPUTED ADDRESS
      # The right side of the expression might also access an array
      # If it does this, then pointer 1 will be set to a different value
      #
      # Instead, store the address on the stack, and set pointer 1 to that address
      # at the moment before assigning a value to that segment
      write_token_and_advance
    end

    expect(@current_token.string == '=')
    write_token_and_advance

    compile_expression

    if is_array
      # Gotta shift things around a bit.
      # Target memory address is below the computed expression value on the stack


      # Therefore, pop computed expression value to temp
      @writer.write_pop('temp', 0)
      # Pop computed memory address to pointer 1
      @writer.write_pop('pointer', 1)
      # Push temp to the stack
      @writer.write_push('temp', 0)
      # Pop top of stack to that 0
      @writer.write_pop('that', 0)
    else
      @writer.write_pop(segment, index)
    end

    expect(@current_token.string == ';')
    write_token_and_advance

    close_structure_tag '</letStatement>'
  end

  def compile_while(idx)
    # 'while' '(' expression ')' '{' statements '}'
    open_structure_tag('While Statement', '<whileStatement>')
    # compiles a while statement
    expect(@current_token.string == 'while')
    write_token_and_advance

    expect(@current_token.string == '(')
    write_token_and_advance

    @writer.write_label("#{WHILE_EXP}#{idx}")

    compile_expression
    @writer.write_arithmetic('not')

    @writer.write_if("#{WHILE_END}#{idx}")

    expect(@current_token.string == ')')
    write_token_and_advance
    expect(@current_token.string == '{')
    write_token_and_advance
    compile_statements
    expect(@current_token.string == '}')
    write_token_and_advance
    @writer.write_goto("#{WHILE_EXP}#{idx}")
    @writer.write_label("#{WHILE_END}#{idx}")

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

  def compile_if(idx)
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

    @writer.write_if("#{IF_TRUE}#{idx}")
    @writer.write_goto("#{IF_FALSE}#{idx}")

    expect(@current_token.string == '{')
    write_token_and_advance

    @writer.write_label("#{IF_TRUE}#{idx}")
    compile_statements

    expect(@current_token.string == '}')
    write_token_and_advance
    @writer.write_goto("#{IF_END}#{idx}")
    @writer.write_label("#{IF_FALSE}#{idx}")

    # else{}
    if @current_token.string == 'else'
      write_token_and_advance
      expect(@current_token.string == '{')
      write_token_and_advance
      compile_statements
      expect(@current_token.string == '}')
      write_token_and_advance
    end
    @writer.write_label("#{IF_END}#{idx}")
    close_structure_tag('</ifStatement>')
  end

  def compile_term # rubocop:disable Metrics/CyclomaticComplexity
    # integerConstant | stringConstant | keywordConstant | varName | varName '[' expression ']'| subroutineCall |
    # '(' expression ')' | unaryOp term
    #
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
      # DONE
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
    case @current_token.string
    when 'true'
      @writer.write_push('constant', 0)
      @writer.write_arithmetic('not')
    when 'false'
      @writer.write_push('constant', 0)
    when 'null'
      @writer.write_push('constant', 0)
    when 'this'
      @writer.write_push('pointer', 0)
    end
    write_token_and_advance
  end

  def compile_int_const
    expect(@current_token.type == 'INT_CONST')
    @writer.write_push('constant', @current_token.string)
    write_token_and_advance
  end

  def compile_string_const
    expect(@current_token.type == 'STRING_CONST')
    string = @current_token.string
    @writer.write_push('constant', string.length)
    @writer.write_call('String.new', 1)
    string.chars.each do |char|
      @writer.write_push('constant', char.ord)
      @writer.write_call('String.appendChar', 2)
    end
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
      kind = @table.kind?(@current_token.string)
      segment = parse_segment(kind)
      index = @table.index?(@current_token.string)
      @writer.write_push(segment, index)
      write_table_info_and_advance
    end
  end

  def compile_array_entry
    # varName '[' expression ']'
    expect(@current_token.type == 'IDENTIFIER')
    kind = @table.kind?(@current_token.string)
    segment = parse_segment(kind)
    index = @table.index?(@current_token.string)
    write_table_info_and_advance

    expect(@current_token.string == '[')
    write_token_and_advance

    compile_expression
    @writer.write_push(segment, index)
    @writer.write_arithmetic('add')
    @writer.write_pop('pointer', 1)
    @writer.write_push('that', 0)

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

  def parse_segment(kind)
    case kind
    when :ARG
      'argument'
    when :VAR
      'local'
    when :FIELD
      'this'
    when :STATIC
      'static'
    end
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
