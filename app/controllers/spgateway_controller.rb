class SpgatewayController < ActionController::Base
  def return
    #比對回傳的 SHA 和自行加密的 SHA 是否一樣 
    hash_key = "CpQYshVvq9eqcUNNoR1lJlkfib8RqiOu"
    hash_iv = "IXTW5Pyygkpl52s8"
    trade_info = spagatway_params['TradeInfo']
    trade_sha = spagatway_params["TradeSha"]

    str = "HashKey=#{hash_key}&#{trade_info}&HashIV=#{hash_iv}"
    check_sha = Digest::SHA256.hexdigest(str).upcase

    #若 SHA 通過認證，將智富通回傳的 TradeInfo 解密，取得參數內容
    if check_sha == trade_sha
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt
      decipher.padding = 0
      decipher.key = hash_key
      decipher.iv = hash_iv

      binary_encrypted = [trade_info].pack('H*') # hex to binary
      plain = decipher.update(binary_encrypted) + decipher.final

      # strip last padding
      if plain[-1] != '}'
        plain = plain[0, plain.index(plain[-1])]
      end
      data = JSON.parse(plain)
    end

    # 根據參數的 MerchantOrderNo，查出 payment 實例
    # 更新相關的 payment 與 order 屬性
    if data
      payment = Payment.find(data['Result']['MerchantOrderNo'].to_i)
      if params['Status'] == 'SUCCESS'
        payment.paid_at = Time.now
      end
      payment.params = data
    end

    if payment&.save
      order = payment.order
      order.update(payment_status: "paid")
      # send paid email
      flash[:notice] = "#{payment.sn} paid"
    else
      flash[:alert] = "Something wrong!!"
    end

    # 動作完成，導回訂單索引頁
    redirect_to orders_path
  end

  private

  # 取出必要參數
  def spagatway_params
    params.slice("Status", "MerchantID", "Version", "TradeInfo", "TradeSha")
  end
  
end