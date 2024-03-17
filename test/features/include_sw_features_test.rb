require 'test_helper'

class IncludeSwFeaturesTest < ActiveSupport::TestCase
  def setup
    Bullet.enable = true
    Bullet.raise = true
    super
  end

  def teardown
    Bullet.enable = false
    Bullet.raise = false
    super
  end

  def bullet_proof
    Bullet.start_request
    yield
    Bullet.perform_out_of_channel_notifications
    Bullet.end_request
  end

  test 'include_sw include needed and exclude not needed attributes when constructing models instance' do
    assert_raise(Bullet::Notification::UnoptimizedQueryError) do
      bullet_proof { User.all.map(&:bought_items).each(&:load) }
    end

    assert_nothing_raised do
      bullet_proof { User.includes_sw(:User).all.map(&:bought_items).each(&:load) }
    end
  end

end