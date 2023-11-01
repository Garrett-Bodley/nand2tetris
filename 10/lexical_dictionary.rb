# frozen_string_literal: true

class JackTokenizer
  class LexicalDictionary
    KEYWORDS = [
      /^boolean$/,
      /^char$/,
      /^class$/,
      /^constructor$/,
      /^do$/,
      /^else$/,
      /^false$/,
      /^field$/,
      /^function$/,
      /^if$/,
      /^int$/,
      /^let$/,
      /^method$/,
      /^null$/,
      /^return$/,
      /^static$/,
      /^this$/,
      /^true$/,
      /^var$/,
      /^void$/,
      /^while$/
    ].freeze

    SYMBOLS = [
      /^\{$/,
      /^\}$/,
      /^\($/,
      /^\)$/,
      /^\[$/,
      /^\]$/,
      /^\.$/,
      /^,$/,
      /^;$/,
      /^\+$/,
      /^-$/,
      /^\*$/,
      /^\/$/, # rubocop:disable Style/RegexpLiteral
      /^&$/,
      /^\|$/,
      /^<$/,
      /^>$/,
      /^=$/,
      /^~$/
    ].freeze

    TERMINAL_DICTIONARY = {
      'KEYWORD' => Regexp.union(KEYWORDS),
      'SYMBOL' => Regexp.union(SYMBOLS),
      'INT_CONST' => /\d+/,
      'STRING_CONST' => /"[^\n"]*"/,
      'IDENTIFIER' => /^[a-zA-Z_][a-zA-Z0-9_]*$/
    }

    def self.contains(string)
      TERMINAL_DICTIONARY.each do |_type, pattern|
        return true if string.match?(pattern)
      end
      false
    end

    def self.type(string)
      TERMINAL_DICTIONARY.each do |type, pattern|
        return type if string.match?(pattern)
      end
      'ERROR'
    end
  end
end
