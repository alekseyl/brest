class UserDoc < DocBase

  swagger_schema :UserUpdate, required: [:name],
                 description: 'Editable user schema part' do

    property :name, type: :string, description: 'User name'

  end

  inherit_schema :UserCreate, :UserUpdate, required: [:email, :name],
                 description: 'User model immutable part' do

    property :email, type: :string, description: 'User email'
  end

  inherit_schema :UserPreview, :UserCreate, required: [:id], description: 'Users preview for a feed' do
    property :id, type: :integer, description: 'Item id'
    property :membership, type: :string, enum: User.memberships.keys, description: 'Membership status.'
  end

  inherit_schema :User, :UserPreview, description: 'Full User data model' do
    property :stats, type: :jsonb, '$ref' => :UserStats, description: 'User statistics'
  end

  inherit_schema :UserFullRepresentation, :UserPreview,
                 description: 'Full User data model with admin hidden  comment in jsonb' do
    property :stats, type: :jsonb, '$ref' => :UserStatsWithHiddenAttribute, description: 'User statistics full'
  end
end