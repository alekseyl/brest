class Promotion < ApplicationRecord

# Rails style guided+
  #-------------------- 1. includes and extend --------------
  #-------------------- 2. default scope --------------------
  #-------------------- 3. inner classes --------------------
  #-------------------- 5. attr related macros --------------
  #-------------------- 6. enums ----------------------------
  #-------------------- 7. scopes ---------------------------
  scope :active_by_pattern, -> (codes) {
    codes.blank? ? none : where( "pattern && ARRAY[?]::varchar[]", [*codes.uniq] ).active
  }
  scope :active, -> { where(active: true) }
  #-------------------- 8. has and belongs ------------------
  #-------------------- 9. accept nested macros  ------------
  #-------------------- 10. validation ----------------------
  validate :free_stuff_or_percent
  validate :no_free_stuff!
  validate :no_pattern_overlapping_for_active!, if: :active
  validate :promo_should_promote!
  validate :no_negative_discount!
  validate :pattern_should_be_present
  #-------------------- 11. before/after callbacks ----------
  #-------------------- 12. enums related macros ------------
  #-------------------- 13. delegate macros -----------------
  #-------------------- 14. other macros (like devise's) ----
  #-------------------- should be placed after callbacks ----
  #-------------------- 15. public class methods ------------
  #-------------------- 16. instance public methods ---------
  #-------------------- 17. protected and private methods ---
  def match_items( items )
    return [] if (items.map(&:code) & pattern).blank?
    matched_ids, h_pattern, h_free_stuff = [], pattern.group_by(&:to_s), free_stuff.group_by(&:to_s)
    items.each do |it|
      # we greedy matching till nothing left, and then if pattern is open, and there was
      # a such code on the pattern we continue matching
      if h_pattern[it.code]&.shift || ( ( open || h_free_stuff[it.code]&.shift) && h_pattern[it.code] == [])
        matched_ids << it.id
      end
    end
    # pattern wasn't fully matched, nothing to apply
    return [] unless h_pattern.values.all?(&:blank?)

    h_matched_ids = matched_ids.group_by(&:to_i)
    resulting_items_separation = items.group_by{|it| !!h_matched_ids[it.id]&.shift }
    [
      resulting_items_separation[true],
     *(resulting_items_separation[false] && match_items(resulting_items_separation[false]))
    ]
  end

  def apply_promo(items)
    # match_items([mug1,mug2,tshirt3]) -> [[mug1, mug2]]
    matched_sets = match_items(items)
    promo_total = free_stuff_type? ? calc_free_stuff_discount( matched_sets ) :
      calc_total_percent_discount( matched_sets )

    # [mug1,mug2,tshirt3] -> {1 => [mug1], 2 => [mug2], 3 => [tshirt3]}
    not_matched_items = items.group_by(&:id)
    # {1 => [mug1], 2 => [mug2], 3 => [tshirt3]} -> {1=>[], 2 => [], 3 =>[tshirt3]}
    matched_sets.flatten.each{|item| not_matched_items[item.id]&.shift }
    {
      promo_total: promo_total,
      # {1=>[], 2 => [], 3 =>[tshirt3]} -> [[],[],[tshirt3]] -> [tshirt3]
      left_overs: not_matched_items.values.flatten
    }
  end

  def calc_free_stuff_discount( matched_sets )
    matched_sets.map do |item_set|
      h_pattern = pattern.group_by(&:to_s)
      h_free_stuff = free_stuff.group_by(&:to_s)

      # if the pattern is open and is overlapping with a free stuff,
      # then we need first to match pattern minimum set, then we should
      # substract free stuff from it and then add whats left to the pattern price.
      items_matched_pattern = item_set.group_by{|item| !!h_pattern[item.code].shift }
      # this is a pattern matched stuff
      items_matched_pattern[true].sum(&:price) +
        items_matched_pattern[false]&.reject{|item| h_free_stuff[item.code].shift }&.sum(&:price).to_f
    end.sum
  end

  def calc_total_percent_discount( matched_sets )
    matched_sets.map { |set| set.sum(&:price) * ( 100 - discount ) / 100 }.sum.ceil(1)
  end

  def self.apply_active_promos(items )
    not_yet_matched_items = items.clone

    Promotion.active.map do |promo|
      promo.apply_promo( not_yet_matched_items ).tap{|_self|
        not_yet_matched_items = _self[:left_overs]
      }[:promo_total]
    end.sum + not_yet_matched_items.sum(&:price)
  end

private
  def free_stuff_or_percent
    errors.add( :free_stuff, 'You should add free stuff or set up a discount' ) if discount_type? && free_stuff_type?
  end

  def no_free_stuff!
    errors.add( :discount, "Discount can't be greater than 99%" ) if discount.to_i >= 100
  end

  def no_negative_discount!
    errors.add( :discount, 'Negative discounts incorrect! Use positive integer less than 100' ) if discount.to_i < 0
  end

  def promo_should_promote!
    errors.add( :free_stuff, 'Real promotion should provide either free_stuff or discount! And there are none!' ) if !discount_type? && !free_stuff_type?
  end

  def pattern_should_be_present
    errors.add( :pattern, 'cannot be blank!' ) if pattern.blank?
  end

  def no_pattern_overlapping_for_active!
    overlapping_pattern_promos = Promotion.active_by_pattern(pattern)
    overlapping_pattern_promos = overlapping_pattern_promos.where.not(id: id) if id
    return if overlapping_pattern_promos.blank?
    errors.add(:pattern, "Promotion pattern #{pattern} overlaps with active promotions: #{overlapping_pattern_promos.map{|it| [it.id, "[#{it.pattern.join(', ')}]"]}.join(', ')}")
  end

  def free_stuff_type?
    !free_stuff.blank?
  end

  def discount_type?
    discount.to_i > 0
  end

end
