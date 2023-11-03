# frozen_string_literal: true

require_relative 'lexical_dictionary'
require_relative 'token'
require 'pry-nav'

# Reads a single file and tokenizes each line
class JackTokenizer # rubocop:disable Metrics/ClassLength
  attr_accessor :current_line, :errors, :lines, :line_num, :current_token, :tokens

  InvalidCharacter = Class.new(StandardError)
  InvalidExpression = Class.new(StandardError)
  INLINE_COMMENT = %r{(?<=\S)\s*//.*}.freeze
  # COMMENT_LINE = %r{^//.*$}.freeze
  # API_COMMENT_LINE = %r{^/\*\*.*\*/$}.freeze
  # API_COMMENT_MULTI_START = %r{^(?!\s*.*\*/\s*$)/\*\*.*$}.freeze
  # API_COMMENT_MULTI_END = %r{^(?!/\*\*).*\*/$}.freeze
  # EMPTY = %r{^$}.freeze # rubocop:disable Style/RegexpLiteral

  def initialize(filepath)
    @file = File.open(filepath)
    @lines = @file.readlines(chomp: true).map(&:strip)
    # current line is an array resulting from calling .split on the next line
    # @line_num = 1
    # @current_line = @lines.first
    @tokens = []
    @errors = []
  end

  def more_lines?
    @lines.empty?
  end

  def errors?
    @errors.count.positive?
  end

  def scan_lines
    @line_num = 1
    skip_empty_or_comments
    until @lines.empty?
      # binding.pry
      line = sanitize_line(@lines.shift)
      scan_line(line)
      @line_num += 1
      skip_empty_or_comments
    end
  end

  def scan_line(string) # rubocop:disable Metrics/MethodLength
    until string.empty?
      char = string[0]
      if LexicalDictionary.contains(char)
        # if valid char and not an edge case
        sub_s = maximal_munch(string)
        type = LexicalDictionary.type(sub_s)
        token = Token.new(type, sub_s, @line_num)
        @tokens << token
        string.sub!(sub_s, '')
      else
        # handle edge cases
        case char
        when ' '
          # consume and ignore spaces
          string.sub!(' ', '')
        when '"'
          handle_single_quote(string)
        else
          # If it's not a space or double quote it's an invalid character
          # therefore, generate an error token to report at the end of scanning process
          string.sub!(char, '')
          type = LexicalDictionary.type(char)
          error = Token.new(type, char, @line_num)
          @errors << error
        end
      end
    end
  end

  def maximal_munch(string)
    return string[0] if string.length == 1

    sub_s = string[0]
    cur = 2
    while LexicalDictionary.contains(sub_s) && sub_s.length < string.length
      sub_s = string.slice(0, cur)
      cur += 1
    end
    sub_s.slice(0, cur - 2)
  end

  def string_max_munch(string)
    # either returns a valid string literal or consumes the rest of the line
    cur = 1
    sub_s = string.slice(0, cur)
    until sub_s.match?(/"[^\n"]*"/) || sub_s.length == string.length
      cur += 1
      sub_s = string.slice(0, cur)
    end
    sub_s
  end

  def handle_single_quote(string) # rubocop:disable Metrics/MethodLength
    sub_s = string_max_munch(string)
    type = LexicalDictionary.type(sub_s)
    string.sub!(sub_s, '')
    if type == 'ERROR'
      token = Token.new(type, sub_s, @line_num)
      @errors << token
    else
      # remove quotation marks
      stripped_s = sub_s.slice(1, sub_s.length - 2)
      token = Token.new(type, stripped_s, @line_num)
      @tokens << token
    end
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
    while !@lines.empty? && LexicalDictionary.comment?(@lines.first)
      if @lines.first.match?(LexicalDictionary::API_COMMENT_MULTI_START)
        skip_multi_line_comment
      else
        @lines.shift
        @line_num += 1
      end
    end
  end

  def skip_multi_line_comment
    return unless @lines.first.match(LexicalDictionary::API_COMMENT_MULTI_START)

    @lines.shift && @line_num += 1 until @lines.first.match?(LexicalDictionary::API_COMMENT_MULTI_END)
    @lines.shift
    @line_num += 1
  end

  def sanitize_line(string)
    string.sub(INLINE_COMMENT, '').strip
  end
end

# require 'pathname'; require_relative 'jack_tokenizer'; path = Pathname.new(File.expand_path('Square/Main.jack')); tokenizer = JackTokenizer.new(path)
