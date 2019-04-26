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

  def generate_form_data(return_url)
    spgateway_data = {
      MerchantID: "MS36020511",
      Version: 1.4,
      RespondType: "JSON",
      TimeStamp: @payment.created_at.to_i,
      MerchantOrderNo: "#{@payment.id}AC",
      Amt: @payment.amount,
      ItemDesc: @payment.order.name,
      Email: @payment.order.user.email,
      LoginType: 0,
      ReturnURL: return_url
    }

    spgateway_data.to_query
  end

end