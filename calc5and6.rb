require "byebug"

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

# grammar rules (attempt):
# algebra: parens ((+|-|*|/) parens)*
# expr: term ((+|-|) term)*
# term: factor ((MULT|DIV)  factor)*
# parens: p_open* (parens|expr) p_close*


# grammar rules (proposed solution):
# expr: term (( + | - |) term)*
# term: parens ((MULT|DIV)  parens)*
# parens: pOPEN parens|expr pCLOSE
# factor: int | pOPEN expr pCLOSE



class Interpreter

  def initialize(text)
    @text = text
    @tokens = []
    tokenize
  end

  def lookahead
    @tokens[0]
  end

  # lexer code
  def tokenize
    @text.scan(/[[:digit:]]+|[[:punct:]]/) do |match|
      case match
      when "+"
        @tokens << Token.new(type: "plus", value: match)
      when "-"
        @tokens << Token.new(type: "minus", value: match)
      when "*"
        @tokens << Token.new(type: "times", value: match)
      when "/"
        @tokens << Token.new(type: "division", value: match)
      when "("
        @tokens << Token.new(type: "pOPEN", value: match)
      when ")"
        @tokens << Token.new(type: "pCLOSE", value: match)
      else
        @tokens << Token.new(type: "int", value: match.to_i)
      end
    end
    
    @tokens << Token.new(type: "eof", value: nil)
  end

  def eat(token_type)
    token = @tokens.shift
    return token if token.type == token_type

    raise "Invalid Syntax, expected #{token_type}"
  end

  # Rules
  def factor
    return eat("int").value if lookahead.type != "pOPEN"

    eat "pOPEN"
    result = expr
    eat "pCLOSE"
    return result
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

  def expr
    result = term
    while ["plus", "minus"].include? lookahead.type
      token = lookahead
      if token.type == "plus"
        eat "plus"
        result = result + term
      elsif token.type == "minus"
        eat "minus"
        result = result - term
      end
    end
    
    result
  end

  def parens
    return expr if lookahead.type != "pOPEN"

    eat "pOPEN"
    result = parens
    eat "pCLOSE"

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
