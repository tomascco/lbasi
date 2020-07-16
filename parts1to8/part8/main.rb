
loop do
  print "ipcl> "
  text = gets.chomp
  tokens = Tokenizer.new.tokenize(text)
  tree = Parser.new(tokens).expr
  puts Interpreter.new.interpret(tree)
end
