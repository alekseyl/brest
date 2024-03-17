class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :update, :destroy]
  before_action :render_not_found, unless: -> { @item }, only: [:show, :update, :destroy]

  # GET /items
  def index
    render_ok( items: Item.paginate(per_page, current_page).order(:id).as_json(:Item) )
  end

  # GET /items/1
  def show
    render_ok( item: @item.as_json(:Item) )
  end

  # POST /items
  def create
    render_safe(:item) { Item.create!(item_creation_params).as_json(:Item) }
  end

  # PATCH/PUT /items/1
  def update
    render_safe(:item) { @item.update!(item_update_params) && @item.as_json(:Item) }
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    head :no_content, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find_by_id(params[:id])
    end

    def item_creation_params
      params.require(:item).permit_sw(:ItemInput)
    end

    def item_update_params
      params.require(:item).permit_sw(:ItemUpdate)
    end
end
