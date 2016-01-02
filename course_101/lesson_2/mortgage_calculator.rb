require "yaml"

CURRENCIES = YAML.load_file('mortgage_calculator_currencies.yml')
currency = CURRENCIES['USD']

def integer?(input)
  (/^\d*$/).match(input)
end

def number?(input)
  (/^\d*\.?\d*$/).match(input)
end

def prompt(message)
  puts "=> #{message}"
end

loop do
  prompt("Welcome to Mortgage Calculator!")

  loan_amount = ''
  loop do
    prompt("What is the loan amount?")
    loan_amount = gets.chomp

    break if number?(loan_amount)
    prompt("Hmm... That does not look like a valid amount.")
  end

  interest_rate = ''
  loop do
    prompt("What is the Annual Percentage Rate (APR)?")
    interest_rate = gets.chomp

    break if number?(interest_rate)
    prompt("Hmm... That does not look like a valid rate.")
  end

  loan_length_years = ''
  loop do
    prompt("What is the loan length (in years)?")
    loan_length_years = gets.chomp

    break if integer?(loan_length_years)
    prompt("Hmm... That does not look like a valid length.")
  end

  monthly_interest_rate = interest_rate.to_f / 100 / 12
  loan_length_months    = loan_length_years.to_i * 12
  monthly_payment       = (loan_amount.to_f * (monthly_interest_rate * (1 + monthly_interest_rate)**loan_length_months)) /
                          ((1 + monthly_interest_rate)**loan_length_months - 1)
  cost_of_mortgage      = monthly_payment * loan_length_months

  prompt("Monthly payment: #{currency}#{monthly_payment.round(2)}")
  prompt("Total cost of mortgage: #{currency}#{cost_of_mortgage.round(2)}")

  prompt("Would you like to calculate another mortgage? (y or n)")
  answer = gets.chomp

  break unless answer.downcase.start_with?('y')
end

prompt("Thanks for using Mortgage Calculator. Good bye!")