class PromotionsController < ApplicationController
  before_action :set_promotion, only: [:show, :update, :destroy]
  before_action :render_not_found, unless: -> { @promotion }, only: [:show, :update, :destroy]

  def index
    render_ok( promotions: Promotion.paginate(per_page, current_page).as_json(:Promotion) )
  end

  def show
    render_ok( promotion:  @promotion.as_json(:Promotion) )
  end

  def create
    render_safe(:promotion) { Promotion.create!(promo_creation_params).as_json(:Promotion) }
  end

  def update
    render_safe(:promotion) { @promotion.update!(promo_creation_params) && @promotion.as_json(:Promotion) }
  end

  def destroy
    @promotion.destroy
    head :no_content, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion
      @promotion = Promotion.find_by_id(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def promo_creation_params
      params.require(:promotion).permit_sw(:PromotionInput)
    end
end
