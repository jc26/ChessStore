class ItemPricesController < ApplicationController
  def index
    @active_items = Item.active.alphabetical.to_a
  end

  def new
    @item_price = ItemPrice.new
  end

  def create
    @item_price = ItemPrice.new(item_price_params)
    @item_price.start_date = Date.current
    if @item_price.save
      @item = @item_price.item
      redirect_to item_path(@item), notice: "Changed the price of #{@item.name}."
      format.js
    else
      render action: 'new'
    end
  end

  private
  def item_price_params
    params.require(:item_price).permit(:item_id, :price, :category)
  end

end
