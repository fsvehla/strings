# encoding: utf-8
require 'spec_helper'

describe Strings::Tokenizer do
  describe 'parsing of individual tokens' do
    def self.should_parse_to_a_token_that_dumps_to_original(string)
      it "parses #{ string.inspect } into a token that can be parsed" do
        tokenizer = Strings::Tokenizer.new(string)
        token = tokenizer.parse_next_token

        token.should be
        token.dump.should eq string
      end
    end

    should_parse_to_a_token_that_dumps_to_original("\n")
    should_parse_to_a_token_that_dumps_to_original("  ")
    should_parse_to_a_token_that_dumps_to_original('"Hello"')
    should_parse_to_a_token_that_dumps_to_original("=")
    should_parse_to_a_token_that_dumps_to_original("/* No comment */")
  end
end

