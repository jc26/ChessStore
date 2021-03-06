class OrderItemsController < ApplicationController

  before_action :check_login
  before_action :set_order_item, only: [:edit, :update, :toggle]
  authorize_resource

  def edit
  end

  def update
    respond_to do |format|
      unless params[:quantity].nil?
        @order_item.update_attribute(:quantity, params[:quantity])
        if params[:quantity].match(/shipped/)
          @order_item.update_attribute(:shipped_on, Date.today)
          flash[:notice] = "The order item has been shipped on #{@order_item.shipped_on.strftime('%m/%d/%y')}"
        end
        redirect_to orders_path
      end
    end
  end

  def toggle
    respond_to do |format|
      if params[:status] == 'shipped'
        @order_item.shipped
        flash[:notice] = "#{@order_item.quantity} orders of #{@order_item.item.name} have been shipped."
      else
        @order_item.unshipped
        flash[:notice] = "#{@order_item.quantity} orders of #{@order_item.item.name} have been unshipped."
      end
      @order_item.save!
      @order = Order.find(params[:order_id])
      if params[:from_dashboard]
        @pending_orders = Order.not_shipped.chronological.to_a
      end
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
