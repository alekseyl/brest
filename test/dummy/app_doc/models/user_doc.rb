class UserDoc < DocBase
  # models hierarchy:
  #      UserBase
  #     |        \
  # UserCreate   UserUpdate
  #    |
  # UserPreview
  #   |      \
  # User    UserFullPreview
  #   |
  # UserAdminView

  swagger_schema :UserBase, required: [:name], description: 'Editable user schema part' do
    property :name, type: :string, description: 'User name'
  end

  inherit_schema :UserUpdate, :UserBase, required: [:name], description: 'User model updatable part, with nested attrs' do
    property :user_profile_attributes, type: :UserProfileInput, description: 'User profile nested attributes'
  end

  inherit_schema :UserCreate, :UserBase, required: [:email, :name],
                 description: 'Updatable + immutable after creation parts' do

    property :email, type: :string, description: 'User email'
  end

  inherit_schema :UserPreview, :UserCreate, required: [:id], description: 'Users preview for a feed' do
    property :id, type: :integer, description: 'User id'
    property :membership, type: :string, enum: User.memberships.keys, description: 'Membership status.'
  end

  inherit_schema :UserFullPreview, :UserPreview, required: [:id], description: 'Users preview for a extended feed' do
    array :bought_items, :ItemPreview, description: "Bought Items previews"
  end

  inherit_schema :User, :UserPreview, description: 'Full User data model' do
    property :stats, type: :jsonb, '$ref' => :UserStats, description: 'User statistics'
    property :user_profile, type: :UserProfile, description: 'User full profile'

    array :bought_items, :Item, description: "Bought Items with attributes"
  end

  inherit_schema :UserAdminView, :UserPreview,
                 description: 'Full User data model with admin hidden  comment in jsonb' do

    property :stats, type: :jsonb, '$ref' => :UserStatsWithHiddenAttribute, description: 'User statistics full'
  end
end