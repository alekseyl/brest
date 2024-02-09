class CartController < ApplicationController
  def items_total
    render_safe(:total) {
      # ActiveRecord will return distinct values, but that's not customer actually want
      @distinct_items = Item.by_ids(item_ids).group_by(&:id)
      @cart_items = item_ids.group_by(&:to_i)
                            .transform_values { |same_ids| [@distinct_items[same_ids.first]] * same_ids.length }.values.flatten

      Promotion.apply_active_promos(@cart_items)
    }
  end

  protected
  def item_ids
    @cart_item_ids ||= ( params[:ids].is_a?(String) && params[:ids].split(',') || params[:ids].is_a?(Array) && params[:ids]|| [] )
      .map(&:to_i).compact
  end
end