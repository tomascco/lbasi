class Token
  attr_reader :type, :value

  def initialize(type:, value:)
    @type = type
    @value = value
  end
  def to_s
    "Token type: #{type}, value: #{@value}"
  end
end

class Tokenizer
  def tokenize(text)
    tokens = []
    text.scan(/[[:digit:]]+|[[:punct:]]/) do |match|
      case match
      when "+"
        tokens << Token.new(type: "plus", value: match)
      when "-"
        tokens << Token.new(type: "minus", value: match)
      when "*"
        tokens << Token.new(type: "times", value: match)
      when "/"
        tokens << Token.new(type: "division", value: match)
      when "("
        tokens << Token.new(type: "lPAREN", value: match)
      when ")"
        tokens << Token.new(type: "rPAREN", value: match)
      else
        tokens << Token.new(type: "int", value: match.to_i)
      end
    end
    tokens << Token.new(type: "eof", value: nil)

    tokens
  end
end
