require "yaml"
MESSAGES = YAML.load_file('calculator_messages.yml')

def prompt(message)
  puts "=> #{message}"
end

def integer?(num)
  num.to_i.to_s == num
end

def float?(num)
  num.to_f.to_s == num
end

def number?(input)
  float?(input) || integer?(input)
end

def operation_to_message(op)
  msg = case op
        when '1'
          'Adding'
        when '2'
          'Subtracting'
        when '3'
          'Multiplying'
        when '4'
          'Dividing'
        end
  msg
end

prompt(MESSAGES['welcome'])

name = ''
loop do
  name = gets.chomp

  if name.empty?
    prompt(MESSAGES['name_invalid'])
  else
    break
  end
end

prompt("#{MESSAGES['hello_prefix']} #{name}!")

loop do
  number1 = ''
  loop do
    prompt(MESSAGES['first_number'])
    number1 = gets.chomp

    if number?(number1)
      break
    else
      prompt(MESSAGES['number_invalid'])
    end
  end

  number2 = ''
  loop do
    prompt(MESSAGES['second_number'])
    number2 = gets.chomp

    if number?(number2)
      break
    else
      prompt(MESSAGES['number_invalid'])
    end
  end

  prompt(MESSAGES['operator_prompt'])

  operator = ''
  loop do
    operator = gets.chomp

    if %w(1 2 3 4).include?(operator)
      break
    else
      prompt(MESSAGES['operator_invalid'])
    end
  end

  prompt("#{operation_to_message(operator)} the two numbers...")

  result = case operator
           when '1'
             number1.to_i + number2.to_i
           when '2'
             number1.to_i - number2.to_i
           when '3'
             number1.to_i * number2.to_i
           when '4'
             number1.to_f / number2.to_f
           end

  prompt("#{MESSAGES['result_prefix']} #{result}")

  prompt(MESSAGES['run_again'])
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt(MESSAGES['good_bye'])