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
    @current_line = @lines.shift

    @line_num = 1
    @start = 0
    @current = 0

    @tokens = []
    @errors = []
  end

  def more_lines?
    @lines.empty?
  end

  def scan_tokens
    until eof?
      @start = @current
      scan_token
    end
    @tokens << Token.new('EOF', nil, @line_num)
    @tokens
  end

  # rename to advance?
  def scan_token
    char = advance
    case char
    when '{'
      add_token('SYMBOL')
    when '}'
      add_token('SYMBOL')
    when '('
      add_token('SYMBOL')
    when ')'
      add_token('SYMBOL')
    when '['
      add_token('SYMBOL')
    when ']'
      add_token('SYMBOL')
    when '.'
      add_token('SYMBOL')
    when ','
      add_token('SYMBOL')
    when ';'
      add_token('SYMBOL')
    when '+'
      add_token('SYMBOL')
    when '-'
      add_token('SYMBOL')
    when '*'
      add_token('SYMBOL')
    when '/'
      # SPECIAL CASE REQUIRES EXTRA LOGIC
      if(match('/'))
        
      end
      add_token('SYMBOL')
    when '&'
      add_token('SYMBOL')
    when '|'
      add_token('SYMBOL')
    when '<'
      add_token('SYMBOL')
    when '>'
      add_token('SYMBOL')
    when '='
      add_token('SYMBOL')
    when '~'
      add_token('SYMBOL')
    else
      @errors << [@line_num, 'Unexpected character']
    end
  end

  def match(expected)
    return false if eof?
    return false if @current_line[@current] != expected

    @current += 1
    true
  end

  def advance
    char = @current_line[@current]
    @current += 1
    char
  end

  def peek
    return "\0" if @current > @current_line.length - 1

    @current_line[@current]
  end

  def next_line
    @current_line = @lines.shift
    @line_num += 1
  end

  def add_token(type)
    string = @current_line.slice(@start, @current)
    @tokens << Token.new(type, string, @line_num)
  end

  def eof?
    lines.empty? && @current >= @current_line.length
  end

  def sanitize_line(string)
    string.sub(INLINE_COMMENT, '').strip
  end
end

# require 'pathname'; require_relative 'jack_tokenizer'; path = Pathname.new(File.expand_path('Test.jack')); tokenizer = JackTokenizer.new(path)
