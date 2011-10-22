module Strings
  class Definition
    def initialize
      @key_token     = nil
      @value_token   = nil
      @comment_token = nil
    end

    attr_accessor(:key_token, :value_token, :comment_token)
  end
end

