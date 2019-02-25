class Admin::ProductsController < Admin::AdminController
  before_action :set_product, only: [:show, :update, :edit, :destroy]

  def index
    @products = Product.page(params[:page]).per(15)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: "product was created"
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: "product was updated"
    else
      render :edit
    end
  end

  def destroy
    @product.destroly
    redirect_to admin_products_path, alert: "product was deleted"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image)
  end

end
