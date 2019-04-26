class Spgateway
  mattr_accessor :merchant_id
  mattr_accessor :hash_key
  mattr_accessor :hash_iv
  mattr_accessor :url

  def initialize(payment)
    @payment = payment
    self.merchant_id = "MS36020511"
    self.hash_key = "CpQYshVvq9eqcUNNoR1lJlkfib8RqiOu"
    self.hash_iv = "IXTW5Pyygkpl52s8"
    self.url = "https://ccore.spgateway.com/MPG/mpg_gateway"
  end

end