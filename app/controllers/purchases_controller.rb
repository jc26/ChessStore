class PurchasesController < ApplicationController
  before_action :check_login
  authorize_resource

  def new
    @purchase = Purchase.new
  end

  def create
    @purchase = Purchase.new(purchase_params)
    @purchase.date = Date.current
    @reorder = params[:reorder]
    respond_to do |format|
      if @purchase.save
        @item = @purchase.item
        format.html { redirect_to @item, notice: 'Successfully added a purchase for #{@purchase.quantity} #{@purchase.item.name}.' }
        format.json { render action: 'show', status: :created, location: @item }
        @purchase_history = @item.purchases.chronological.to_a
        if @reorder
          @items_need_reorder = Item.all.active.need_reorder.alphabetical.to_a
        end
        flash[:notice] = "#{@purchase.quantity} units of #{@purchase.item.name} have been reordered!"
        format.js
      else
        render action: 'new'
      end
    end
  end

  private
  def purchase_params
    params.require(:purchase).permit(:item_id, :quantity)
  end

end
