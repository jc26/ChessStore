class ItemPricesController < ApplicationController
  before_action :check_login
  authorize_resource

  def new
    @item_price = ItemPrice.new
  end

  def create
    @item_price = ItemPrice.new(item_price_params)
    @item_price.start_date = Date.current
    respond_to do |format|
      if @item_price.save
        @item = @item_price.item
        format.html { redirect_to @item, notice: 'Changed the price of #{@item.name}.' }
        format.json { render action: 'show', status: :created, location: @item }
        @manufacturer_price_history = @item.item_prices.manufacturer.chronological.to_a
        @wholesale_price_history = @item.item_prices.wholesale.chronological.to_a
        display_price = ActionController::Base.helpers.number_to_currency(@item_price.price)
        flash[:notice] = "#{@item_price.category.capitalize} price has been to updated to #{display_price}."
        format.js
      else
        render action: 'new'
      end
    end
  end

  private
  def item_price_params
    params.require(:item_price).permit(:item_id, :price, :category)
  end

end
