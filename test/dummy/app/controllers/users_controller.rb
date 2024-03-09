class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :render_not_found, unless: -> { @user }, only: [:show, :update, :destroy]

  # GET /users
  def index
    render_ok( users: User.paginate(per_page, current_page).order(:id).as_json(:UserPreview) )
  end

  # GET /users/1
  def show
    render_ok( user: @user.as_json(:User) )
  end

  # POST /users
  def create
    render_safe(:user) { User.create!(user_creation_params).as_json(:User) }
  end

  # PATCH/PUT /users/1
  def update
    render_safe(:user) { @user.update!(user_update_params) && @user.as_json(:User) }
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    head :no_content, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_id(params[:id])
    end

    def user_creation_params
      params.require(:user).permit_sw(:UserCreate)
    end

    def user_update_params
      params.require(:user).permit_sw(:UserUpdate)
    end
end
