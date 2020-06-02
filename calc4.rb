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

# grammar rules:
# term: term ((+ | -) term)*
# term: factor ((MULT|DIV) factor)*
# factor: "int"

class Interpreter

  def initialize(text)
    @text = text
    @tokens = []
    tokenize
  end

  def expr
    result = term

    while ["plus", "minus"].include? @tokens[0].type
      token = @tokens[0]
      if token.type == "plus"
        eat "plus"
        result = result + term
      elsif token == "minus"
        eat "minus"
        result = result - term
      end
    end
    
    result
  end

  private

  # lexer code
  def tokenize
    @text.scan(/[[:digit:]]+|[[:punct:]]/) do |match|
      if match == "+"
        @tokens << Token.new(type: "plus", value: match)
      elsif match == "-"
        @tokens << Token.new(type: "minus", value: match)
      elsif match == "*"
        @tokens << Token.new(type: "times", value: match)
      elsif match == "/"
        @tokens << Token.new(type: "division", value: match)
      else
        @tokens << Token.new(type: "int", value: match.to_i)
      end
    end
    
    @tokens << Token.new(type: "eof", value: nil)
  end

  def eat(token_type)
    token = @tokens.shift
    return token if token.type == token_type

    raise "Invalid Syntax"
  end

  # Rules
  def factor
    eat("int").value
  end

  def term
    result = factor

    while ["times", "division"].include? @tokens[0].type
      token = @tokens[0]
      if token.type == "times"
        eat "times"
        result = result * factor
      elsif token.type == "division"
        eat "division"
        result = result / factor
      end
    end

    result
  end
end

loop do
  print "calc> "
  text = gets.chomp
  interpreter = Interpreter.new(text)
  result = interpreter.expr
  puts result
end
