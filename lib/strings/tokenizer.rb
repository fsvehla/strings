module Strings
  class Tokenizer
    class Token
      def initialize(content)
        @content = content
      end

      def dump
        if as_string
          as_string.to_s
        end
      end

      attr_accessor :content

      protected

      def as_string
        @content
      end
    end

    class WhitespaceToken < Token
    end

    class CommentToken < Token
      def as_string
        ['/*', @content, '*/'].join
      end
    end

    class QuotedStringToken < Token
      def as_string
        ['"', @content, '"'].join
      end
    end

    class EqualsToken < Token
    end

    class SemicolonToken < WhitespaceToken
    end

    def initialize(source)
      @bom = source.bytes.take(2) == [255, 254]

      if @bom
        STDERR.puts "WARNING: BOM detected and stripped"

        @source = source[1..-1].encode(Encoding::UTF_8)
      else
        @source = source.encode(Encoding::UTF_8)
      end

      @scanner = StringScanner.new(@source)
    end

    def eos?
      @scanner.eos?
    end

    def tokens
      @_tokens ||= parse_tokens
    end


    def parse_next_token
      parse_comment || parse_quoted_string || parse_semicolon || parse_whitespace || parse_equals
    end

    protected

    def parse_tokens
      tokens = []

      while token = parse_next_token
        tokens << token
      end

      if @scanner.restsize > 0
        raise("Parser error: Unparsed: #{ @scanner.rest.inspect } of string with #{ @source.encoding }")
      end

      tokens
    end

    #== Tokens

    CommentLeftDelimiter  = Regexp.new(Regexp.escape('/*'))
    CommentRightDelimiter = Regexp.new(Regexp.escape('*/'))

    def parse_comment
      if @scanner.skip(CommentLeftDelimiter)
        content = @scanner.scan_until(CommentRightDelimiter)[0..-3]
        CommentToken.new(content)
      end
    end

    DoubleQuotesRegexp = Regexp.new('"')

    def parse_quoted_string
      if @scanner.skip(DoubleQuotesRegexp)
        content = @scanner.scan_until(DoubleQuotesRegexp)[0..-2]
        QuotedStringToken.new(content)
      end
    end

    WhiteSpaceRegexp = Regexp.new('\s+')

    def parse_whitespace
      if content = @scanner.scan(WhiteSpaceRegexp)
        WhitespaceToken.new(content)
      end
    end

    # TODO: StringScanner that supports strings
    SemiColonRegexp = Regexp.new(';')

    def parse_semicolon
      if @scanner.scan(SemiColonRegexp)
        SemicolonToken.new(';')
      end
    end

    EqualsRegexp = Regexp.new('=')

    def parse_equals
      if @scanner.scan(EqualsRegexp)
        return EqualsToken.new('=')
      end
    end
  end
end

