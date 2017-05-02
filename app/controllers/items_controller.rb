class ItemsController < ApplicationController
  include ChessStoreHelpers::Cart

  before_action :check_login, except: [:index, :show]
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def add_item
    add_item_to_cart(params[:id])
    @item = Item.find(params[:id])
    redirect_to items_path, notice: "#{@item.name} was added to your cart."
  end

  # def remove_item
  #   remove_item_from_cart(params[:id])
  #   @item = Item.find(params[:id])
  #   redirect_to cart_path, notice: "The item was removed from your cart."
  # end

  def index
    if logged_in?
      @items_in_cart = get_list_of_items_in_cart
      @total_cost = calculate_cart_items_cost
      @size_of_cart = get_size_of_cart
    end
    if params[:search]
      @active_items = Item.search(params[:search]).alphabetical
    else
      @active_items = Item.active.all.alphabetical
      @boards = Item.active.for_category('boards').alphabetical.paginate(:page => params[:page]).per_page(10)
      @pieces = Item.active.for_category('pieces').alphabetical.paginate(:page => params[:page]).per_page(10)
      @clocks = Item.active.for_category('clocks').alphabetical.paginate(:page => params[:page]).per_page(10)
      @supplies = Item.active.for_category('supplies').alphabetical.paginate(:page => params[:page]).per_page(10)
      @inactive_items = Item.inactive.alphabetical.to_a
    end
  end

  def show
    # get the price history for this item
    @manufacturer_price_history = @item.item_prices.manufacturer.chronological.to_a
    @wholesale_price_history = @item.item_prices.wholesale.chronological.to_a
    @purchase_history = @item.purchases.chronological.to_a
    # everyone sees similar items in the sidebar
    @similar_items = Item.for_category(@item.category).active.alphabetical.to_a - [@item]
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to item_path(@item), notice: "Successfully created #{@item.name}."
    else
      render action: 'new'
    end
  end

  def update
    if @item.update(item_params)
      redirect_to item_path(@item), notice: "Successfully updated #{@item.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "Successfully removed #{@item.name} from the system."
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :color, :category, :weight, :inventory_level, :reorder_level, :active)
  end

end
