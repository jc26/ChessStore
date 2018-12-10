class ItemsController < ApplicationController
  include ChessStoreHelpers::Cart

  before_action :check_login, except: [:index, :show]
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_heading
  authorize_resource

  def add_item
    add_item_to_cart(params[:id])
    @item = Item.find(params[:id])
    respond_to do |format|
      @items_in_cart = get_list_of_items_in_cart
      @total_cost = calculate_cart_items_cost
      @size_of_cart = get_size_of_cart
      flash[:notice] = "#{@item.name} was added to your cart."
      format.js
    end
  end

  def remove_item
    remove_item_from_cart(params[:id])
    @item = Item.find(params[:id])
    redirect_to cart_path, notice: "#{@item.name} was removed from your cart."
  end

  def index
    if params[:search]
      @active_items = Item.active.search(params[:search]).alphabetical
      @inactive_items = Item.inactive.search(params[:search]).alphabetical.paginate(:page => params[:page]).per_page(10)
      if @active_items.empty? && @inactive_items.empty?
        redirect_to items_path, notice: "Sorry, there are no items with name similar to '#{params[:search]}.'"
      end
    else
      @active_items = Item.active.all.alphabetical
      @inactive_items = Item.inactive.alphabetical.paginate(:page => params[:page]).per_page(10)
    end
    @boards = @active_items.for_category('boards').paginate(:page => params[:page]).per_page(10)
    @pieces = @active_items.for_category('pieces').paginate(:page => params[:page]).per_page(10)
    @clocks = @active_items.for_category('clocks').paginate(:page => params[:page]).per_page(10)
    @supplies = @active_items.for_category('supplies').paginate(:page => params[:page]).per_page(10)
  end

  def show
    # get the price history for this item
    @manufacturer_price_history = ItemPrice.for_item(@item).manufacturer.chronological.to_a
    @wholesale_price_history = ItemPrice.for_item(@item).wholesale.chronological.to_a
    @purchase_history = Purchase.for_item(@item).chronological.to_a
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
    @item.active = false;
    if @item.save
      # if @item.picture
      #   uploaded_io = params[:item][:picture]
      #   File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      #     file.write(uploaded_io.read)
      #   end
      # end
      redirect_to item_path(@item), notice: "Successfully created #{@item.name} (currently inactive)."
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
    if @item.destroy
      redirect_to items_path, notice: "Successfully removed #{@item.name} from the system."
    else
      redirect_to items_path(@item), notice: "This item has been made inactive. It cannot be destroyed. All unshipped and unpaid order items have been removed."
    end
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :color, :category, :weight, :inventory_level, :reorder_level, :picture, :active)
  end

  def set_heading
    @title = "ITEMS"
    @path_name = "/items"
  end

end
