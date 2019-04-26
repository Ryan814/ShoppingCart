class OrdersController < ApplicationController

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def create
    # manually check if user logged in
    if current_user.nil?
      # sotre order data in session so we cna retrieve it lager
      session[:new_oreder_data] = params[:order]
      #  redirect to devise login page
      redirect_to new_user_session_path
    else
      @order = current_user.orders.new(order_params)
      @order.sn = Time.now.to_i
      @order.add_order_items(current_cart)
      @order.amount = current_cart.subtotal
      if @order.save
        current_cart.destroy
        redirect_to orders_path, notice: "new order created"
      else
        @items = current_cart.cart_items
        render "carts/show"
      end
    end

    def update
      @order = current_user.orders.find(params[:id])
      if @order.shipping_status == "not_shipped"
        @order.shipping_status = "cancelled"
        @order.save
        redirect_to orders_path, alert: "order##{@order.sn} cancelled."
      end
    end

    def checkout_spgateway
      @order = current_user.orders.find(params[:id])
      if @order.payment_status != "not_paid"
        flash[:alert] = "Order has been paid."
        redirect_to orders_path
      else
        @payment = Payment.create!(
          sn: Time.now.to_i,
          order_id: @order.id,
          amount: @order.amount
        )
        # spgateway_data = {
        #   MerchantID: "MS36020511",
        #   Version: 1.4,
        #   RespondType: "JSON",
        #   TimeStamp: Time.now.to_i,
        #   MerchantOrderNo: "#{@payment.id}AC",
        #   Amt: @order.amount,
        #   ItemDesc: @order.name,
        #   Email: @order.user.email,
        #   LoginType: 0,
        #   ReturnURL: spgateway_return_url
        # }.to_query

        # spgateway_data = 
        # Spgateway.new(@payment).generate_form_data(spgateway_return_url)

        # hash_key = "CpQYshVvq9eqcUNNoR1lJlkfib8RqiOu"
        # hash_iv = "IXTW5Pyygkpl52s8"

        # cipher = OpenSSL::Cipher::AES256.new(:CBC)
        # cipher.encrypt
        # cipher.key = hash_key
        # cipher.iv  = hash_iv
        # encrypted = cipher.update(spgateway_data) + cipher.final
        # aes = encrypted.unpack('H*').first

        # str = "HashKey=#{hash_key}&#{aes}&HashIV=#{hash_iv}"
        # sha = Digest::SHA256.hexdigest(str).upcase

        # @merchant_id = "MS36020511"
        # @trade_info = aes
        # @trade_sha = sha
        # @version = "1.4"

        # @merchant_id = spgateway_data[:MerchantID]
        # @trade_info = spgateway_data[:TradeInfo]
        # @trade_sha = spgateway_data[:TradeSha]
        # @version = spgateway_data[:Version]

        render layout: false
      end
    end

  end

  private

  def order_params
    params.require(:order).permit(:name, :phone, :address, :payment_method)
  end
end
