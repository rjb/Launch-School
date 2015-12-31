puts "Welcome to Calculator!"

puts "What is the first number?"
number1 = gets.chomp

puts "What is the second number?"
number2 = gets.chomp

puts "What operation would you like to perform? 1) add 2) subtract 3) multiply 4) divide"
operation = gets.chomp

result =
  if operation == '1'
    number1.to_i + number2.to_i
  elsif operation == '2'
    number1.to_i - number2.to_i
  elsif operation == '3'
    number1.to_i * number2.to_i
  elsif operation == '4'
    number1.to_f / number2.to_f
  else
    "Operation not valid"
  end

puts "Result: #{result}"