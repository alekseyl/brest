class UserProfileDoc < DocBase
  swagger_schema :UserProfileInput, required: [:address, :zip_code, :bio],
                 description: 'Editable user profile schema part' do

    property :address, type: :string, description: 'Users address'

    property :zip_code, type: :string, description: 'Users zip_code address'
    property :bio, type: :string, description: 'Users zip_code address'
  end

  inherit_schema :UserProfile, :UserProfileInput, required: [:id], description: 'Users Profile full' do
    property :id, type: :integer, description: 'User id'
  end
end