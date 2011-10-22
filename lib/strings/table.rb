require 'strscan'
require 'set'

module Strings
  class Table
    # The source need to be encoded in an ASCII derivate. UTF-8 is fine.
    def initialize(source)
      @source = source
    end

    #== Access

    # Returns a Set of keys
    def keys
      definitions.keys.to_set
    end

    # Returns the string value for +key+, or nil
    def fetch(key)
      if definition = definitions[key]
        definition.value_token.content
      end
    end

    alias_method :[], :fetch

    def set(key, value)
      if value == nil
        raise(RuntimeError, 'Refusing to set a key to nil')
      end

      if definition = definitions[key]
        definition.value_token.content = value
        value
      else
        raise(RuntimeError, "Refusing to update non-existing key: #{ key }")
      end
    end

    alias_method :[]=, :set

    def update(keys_and_values)
      keys_and_values.each do |key, value|
        set(key, value)
      end

      return keys_and_values
    end

    # Similar to update, but requires the table to contain all the given keys
    def update_all(keys_and_values)
      given_key_set = Set.new(keys_and_values.keys)

      if keys != given_key_set
        missing = (keys - given_key_set)

        raise(
          RuntimeError,
          "Need to specify all existing keys but missing: #{ missing.to_a.join(', ') }"
        )
      end

      update(keys_and_values)
    end

    #== Conversion

    # Returns a hash of key string and value string pairs.
    def to_hash
      definitions.inject({}) do |accumulator, (key, definition)|
        accumulator[key] = definition.value_token.content
        accumulator
      end
    end

    #== Output

    # Output the string file as a string.
    def dump
      tokens.collect do |token|
        token.dump
      end.join
    end

    private

    def definitions
      @_definitions ||= parse_definitions
    end

    def tokens
      @_tokens ||= tokenize
    end

    def tokenize
      tokenizer = Strings::Tokenizer.new(@source)
      tokenizer.tokens
    end

    def parse_definitions
      definitions = []

      key_token, value_token, comment_token = nil

      tokens.each do |token|
        case token
        when Strings::Tokenizer::QuotedStringToken
          key_token ? value_token = token : key_token = token
        when Strings::Tokenizer::CommentToken
          comment_token = token
        when Strings::Tokenizer::SemicolonToken
          definition = Strings::Definition.new

          definition.key_token     = key_token
          definition.value_token   = value_token
          definition.comment_token = comment_token

          definitions << definition

          key_token, value_token, comment_token = nil
        end
      end

      definitions.inject({}) do |accumulator, definition|
        accumulator[definition.key_token.content] = definition
        accumulator
      end
    end

    attr_accessor :source, :hash
  end
end

