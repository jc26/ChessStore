class OrderItemsController < ApplicationController

  before_action :check_login
  before_action :set_order_item, only: [:edit, :toggle]

  def edit
    # unless params[:status].nil?
    #   if params[:status].match(/shipped/)
    #     @order_item.update_attribute(:shipped_on, Date.today)
    #     flash[:notice] = "The order item has been shipped on #{@order_item.shipped_on.strftime('%m/%d/%y')}"
    #   end
    #   redirect_to orders_path
    # end
  end

  def toggle
    respond_to do |format|
      if params[:status] == 'shipped'
        @order_item.shipped
        # flash[:notice] = "Order Item for #{@order_item.quantity} #{@order_item.item.name} was marked as shipped."
      else
        @order_item.unshipped
      end
      @order_item.save!
      @order = Order.find(params[:order_id])
      format.js
    end
  end

  private
  def set_order_item
    @order_item = OrderItem.find(params[:id])
  end

  def order_item_params
    params.require(:order_item).permit(:order_id, :item_id, :quantity, :shipped_on)
  end

end
