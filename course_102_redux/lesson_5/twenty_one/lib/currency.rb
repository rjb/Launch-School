# Money related actions
module Currency
  CURRENCIES = {
    'US' => '$',
    'UK' => '£',
    'EU' => '€',
    'JP' => '¥'
  }.freeze

  def format_as_currency(amount)
    format "#{Wallet::CURRENCY}%.2f", amount
  end
end
