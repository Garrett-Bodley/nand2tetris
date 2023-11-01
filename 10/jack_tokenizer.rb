# frozen_string_literal: true

require_relative 'lexical_dictionary'
require_relative 'token'

# Reads a single file and tokenizes each line
class JackTokenizer
  attr_accessor :current_line, :lines, :line_num, :current_token, :tokens

  InvalidCharacter = Class.new(StandardError)
  InvalidExpression = Class.new(StandardError)
  INLINE_COMMENT = %r{(?<=\S)\s*//.*}.freeze
  COMMENT_LINE = %r{^//.*$}.freeze
  API_COMMENT_LINE = %r{^/\*\*.*\*/$}.freeze
  API_COMMENT_MULTI_START = %r{^(?!\s*.*\*/\s*$)/\*\*.*$}.freeze
  API_COMMENT_MULTI_END = %r{^(?!/\*\*).*\*/$}.freeze
  EMPTY = %r{^$}.freeze # rubocop:disable Style/RegexpLiteral

  def initialize(filepath)
    @file = File.open(filepath)
    @lines = @file.readlines(chomp: true).map(&:strip)
    # current line is an array resulting from calling .split on the next line
    @line_num = 1
    skip_empty_or_comments
    @current_line = @lines.first
    @tokens = []
  end

  def more_lines?
    @lines.empty?
  end

  def advance
    # return @current_token = tokens.shift unless tokens.empty?

    # advance_line
    # @current_token = @tokens.shift
  end

  def advance_line
    # @current_line = sanitize_line(@lines.shift) if @current_line.empty?
  end

  def scan_line(string)
    # build a substring character by character until it matches one of the terminal dictionary options
    # continue to build substring until it no longer matches
    # remove the last char that made it not match
    # determine what type of terminal token it is, and create a token of that type

    # the above assumes valid input
    # how do we handle errors?
    # If invalid token, create an ERROR token
    # How do we build an error token?
    #   Start building a sub string
    #   It does not match a regex
    #   continue building the substring until we hit a space OR a valid token appears?
    #     ex: ident!fi3r>3
    cur = 0
    sub_s = string.slice(0, cur + 1)
    until string.empty?
      until LexicalDictionary.contains(sub_s)
        char = string[0]
        string.sub(' ', '') && next if char == ' '
      end


      if LexicalDictionary.contains(sub_s)
        sub_s = maximal_munch(cur, sub_s)
        type = LexicalDictionary.type(sub_s)
        @tokens << Token.new(type, sub_s, @line_num)
        @current_line.sub(sub_s, '')
        cur = 0
      else
        char = string.slice(0)
        string.sub(' ', '') && next if char == ' '


      end
    end
  end

  def build_until_match_or_end_of_token(string)
    cur = 0
    sub_s = string[0]
    until LexicalDictionary.contains(sub_s) || string[cur] == ' '
      cur += 1
      sub_s = string.slice(0, cur + 1)
    end
  end

  def maximal_munch(cur, sub_s)
    if LexicalDictionary.contains(sub_s) == false
      raise ArgumentError, "Provided substring not found in Dictionary (given: #{sub_s})"
    end

    while LexicalDictionary.contains(sub_s)
      cur += 1
      sub_s = @current_line.slice(0, cur + 1)
    end
    sub_s.slice(0, cur)
  end



  def token_type
    # returns the type of the current token
    # KEYWORD, SYMBOL, IDENTIFIER, INT_CONST, STRING_CONST
  end

  def keyword
    # returns keyword for current token if token_type == 'KEYWORD'
    # CLASS, METHOD, FUNCTION, CONSTRUCTOR, INT, BOOLEAN, CHAR, VOID, VAR, STATIC, FIELD, LET, DO IF, ELSE, WHILE,
    # RETURN, TRUE, FALSE, NULL, THIS
  end

  def symbol
    # returns the character that is the current token. Only called when token_type == 'SYMBOL'
  end

  def identifier
    # returns the identifier that is the current token. Only called when token_type == 'IDENTIFIER'
  end

  def int_val
    # returns integer value of the current token. Only called when token_type == 'INT_CONST'
  end

  def skip_empty_or_comments
    # check if current line is any type of comment or is empty
    # increment @line_num and remove comment line
    while lines.first.match?(Regexp.union(COMMENT_LINE, API_COMMENT_LINE, API_COMMENT_MULTI_START, EMPTY))
      if lines.first.match?(API_COMMENT_MULTI_START)
        skip_multi_line_comment
      else
        lines.shift
        @line_num += 1
      end
    end
  end

  def skip_multi_line_comment
    return unless lines.first.match(API_COMMENT_MULTI_START)

    lines.shift && @line_num += 1 until lines.first.match?(API_COMMENT_MULTI_END)
    lines.shift
    @line_num += 1
  end

  def sanitize_line(string)
    string.sub(INLINE_COMMENT, '').strip
  end
end

# require 'pathname'; require_relative 'jack_tokenizer'; path = Pathname.new(File.expand_path('Test.jack')); tokenizer = JackTokenizer.new(path)
