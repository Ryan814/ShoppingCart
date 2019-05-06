class Payment < ApplicationRecord
  belongs_to :order

  after_update :update_order_status

  PAYMENT_METHODS = %w(Credit WebATM ATM)
  validates_inclusion_of :payment_method, in: PAYMENT_METHODS

  def deadline
    Date.today + 3.days
  end

  def self.find_and_process(params)
    data = Spgateway.decrypt(params['TradeInfo'], ['TradeSha'])

    # 根據參數的 MerchantOrderNo，查出 payment 實例
    # 更新相關的 payment 與 order 屬性
    if data
      payment = Payment.find(data['Result']['MerchantOrderNo'].to_i)
      if params['Status'] == 'SUCCESS'
        payment.paid_at = Time.now
      end
      payment.params = data
      return payment
    else
      return nil
    end
  end

  def update_order_status
    if self.paid_at
      order = self.order
      order.update(payment_status: "paid")
    end
  end

end
