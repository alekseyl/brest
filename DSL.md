# Brest DSL Ideology

Some time ago I dug an approach for building medium sized REST-API application: [Code-Test-Document](https://medium.com/@leshchuk/code-test-document-9b79921307a5)

For some time I was building a set of helpers around different libraries implementing that approach. 
And I started thinking about improving performance not only for the programmers, but also for the application itself. 
See the idea of partial objects instantiation: [Rails nitro-fast collection rendering with PostgreSQL](https://medium.com/@leshchuk/rails-nitro-fast-collection-rendering-with-postgresql-a5fb07cc215f)

I'm strongly suggest for you to read both of those articles first to get the basic ideas of what are the purpose and benefits. 

This is a full guide for the BRest DSL, the opinionated way to build performant REST-API applications.

# Nested Models 

Each object and model could have a different render projection, 
for instance object preview in the objects feed needs only partial set off attributes, object update from the other side 
also have an updatable ( aka strong parameters ) and restricted from update attributes, e.t.c.

All of this representation could be easily introduced as a tree of swagger-models inheritance.
For instance: 
- BaseModel ( smallest general attributes set shared across all of the models )
  - InputModel / UpdateModel ( enriched attributes set, for instance this models could contain a nested_objects attributes, which are only related to create/update operations)
  - Model ( full object representation )
  

# Adjustments and improvements

A closer integration with a swagger schema and ORMs provides a given set of extended functionalities:
- Schema-base ORM **select**. Using **select_sw** method you can select only restricted set of attributes related to a given swagger model
- Schema-base ORM **includes**. Using **includes_sw** you can automatically include all nested models for a given one.
- Schema-base ORM **as_json** method. Via this method you can ensure that API output for a given object will be limited only to a given swagger-model attributes. 
- Schema-base permit for attributes: **permit_sw**, it allows you to perform quick and proper strong params permission application aligned to the 
  corresponding swagger-model defined schema.

# Additional swagger-blocks helpers and adjustments:

- schemas inheritance with method inherit_schema
- extended sugared property definition: type could point directly to model without '$ref' key verbosity
- **array** — schema helper for a quick array definition 
  - **only_in_schema** — is an additional extended attribute for special array cases when there is a different attribute 
  in a different model with same naming and we need to differ them during permit_schemas generations phase ( to permit array we need for permitted value to be an array ). Should be set to schema name, go to TaskStats schema and search for blocked attribute definition to see the example. 
- **jsonb** type fields integration, it allows field to be defined like an swagger-model and selected as a single field with select_sw 
- virtual/injectable attributes, define at the root — inject at any leaf 
- synthetic attributes — attributes to be added to as_json output, but kept out of DB selection. 
- clear_ext_keys — Swaggerizer internal helper will recursively cleanup all attributes extensions, not allowed in Swagger 2.0 standard. Currently only only_in_schema attribute will be cleaned before schema definition.

# Richer REST-API DSL
There are also some sugar to REST-API definitions:
- Automatic route params extraction, Ex:
```ruby
'cards/{card_id}' # -> parameter(card_id, in: :path)
``` 
- delete_resource, create_resource, update_resource, index_resource, show_resource — ready to gor basic resource routes
- swagger_path_ext — extended path definition method providing route params extraction e.t.c. 
- swagger_many_path — a helper for multiple routes with same answer signature, could be useful for nested resources.

# Integration examples

Lets say we have next models structure, with a set on features mentioned on the graph

```
Admin

      User ( jsonb + arrays + nested attributes ) -- UserProfile
      /  |  \
( mtm bought_items )
      \  |  /
       Item ( s3 images / video, synthetic, includes + nested select on Comment )
          \__Comments (jsonb)
          
```

Look for full swagger definition in folder [test/dummy/app_doc](./test/dummy/app_doc).
Api routes are defined in [test/dummy/app_doc/api folder](./test/dummy/app_doc/api).
Models are defined in [test/dummy/app_doc/models folder](./test/dummy/app_doc/models).

Example of a model definition

```ruby
class UserDoc < DocBase

  swagger_schema :UserBase, required: [:name], description: 'Editable user schema part' do
    property :name, type: :string, description: 'User name'
  end

  inherit_schema :UserUpdate, :UserBase, required: [:name], description: 'User model updatable part' do
    property :user_profile_attributes, type: :UserProfileInput, description: 'User profile nested attributes'
  end

  inherit_schema :UserCreate, :UserBase, required: [:email, :name],
                 description: 'User model immutable after creation part part' do

    property :email, type: :string, description: 'User email'
  end

  inherit_schema :UserPreview, :UserCreate, required: [:id], description: 'Users preview for a feed' do
    property :id, type: :integer, description: 'User id'
    property :membership, type: :string, enum: User.memberships.keys, description: 'Membership status.'
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
```

Controllers integrations
```ruby
   def index
      # equal to:
      # @users = User.all.select( :name, :last_name, :email, :id )
      #              .includes(:avatar)
      @users = User.all.select_sw(:User).includes_sw(:User)
      # equal to:
      #   @users.as_json( only: [:name, :last_name, :email, :id],
      #    include: { avatar: { only: [..] } } )
      render json: { users: @users.as_json(:User) }, status: :ok
    end
    # alternative way of doing things:
    #  render json: { users: User.all.swaggerize_output(:User) }
    
    def create
      @user = User.create(user_params)
      render json: { user: @user.as_json(:User) }, status: :ok
    end
    
    def update
      @user.update(user_params)
      render json: { user: @user.as_json(:User) }, status: :ok
    end
    
    def user_params
      # equal to params.require(:user)
      #        .permit(:password, :password_confirmation, :email,
      #                :name, :last_name, avatar_attributes: [:id, :upload] )
      params.require(:user)
            .permit_sw(:password, :password_confirmation, :UserInput)
    end
```

# DSL features
Brest has 5 major DSL improvements for a swagger-blocks: **jsonb** flag, **inherit_schema** helper, **virtual/inject** attribute setting, **synthetic** attribute.

## inherit_schema
During swagger schemas definitions pretty soon you will face a need of DRYing your models, 
the best way is to create schemas hierarchy. This is achievable via allOf attribute and nested sub schema. 
This construct wrapped into inherit_schema helper. Also attributes required in ancestor will be required in descendants.

Usage:

```ruby
class UserDoc
  include Swagger::Blocks
  
  swagger_schema :UserBase, required: [:name, :last_name] do
    property :name, type: :string
    property :last_name, type: :string
    property :email, type: :string
  end

  inherit_schema :UserInput, :UserBase, required: [:id, :email] do
    property :avatar_attributes, type: :object, '$ref' => :FileInput
  end
end
```

## jsonb
Naming is clearly suggest that a given attribute is used whenever we are facing a jsonb column. 
The major reason for this attribute to be introduced is a problem with the 'nested' model and the column selection.
Obviously this field should not get into includes attributes, as a related model.
Should be selected as a single column, not a model structure, but verified as one.

Example of usage:
```ruby

class AttachmentMetaDoc
include Swagger::Blocks

# jsonb field structure description:
  swagger_schema :FileMeta, required: [:size, :url], description: 'File base meta' do
    property :size, type: :integer, description: 'File size'
    property :url, type: :string, description: 'Signed url'
    property :mime, type: :string, description: 'Mime type'
  
    property :width, virtual: true, type: :integer, description: 'Width for picture'
    property :height, virtual: true, type: :integer, description: 'Height for picture'
  end

  
  inherit_schema :ImageMeta, :FileMeta,
    required: [:size, :url, :width, :height],
    description: 'image meta'  do
    property [:width, :height], inject: true
  end

end

# jsonb attribute meta usage:
swagger_schema :Avatar, description: 'Avatar attributes',
required: [:id, :user_id, :meta] do

    property :id, type: :integer, format: :int64, description: 'Base ID'
    property :user_id, type: :integer, format: :int64, description: 'User id'
    property :meta, type: :jsonb, '$ref' => :ImageMeta, description: 'Image meta'
end
```
Result:

```ruby
Avatar.where(id: 1).select_sw(:Avatar).as_json(:Avatar)

# here how its requested —→
# SELECT "u_files"."id", "u_files"."user_id", "u_files"."meta"
#   FROM "u_files"
#   WHERE "u_files"."type" = 'Avatar' AND "u_files"."id" = 1

# here is the model to compare against standard —→
{
  "id" => 1,
  "user_id" => 2,
  "type" => "Avatar",
  "meta" => {
    "height" => 50,
    "mime" => "image/jpeg",
    "size" => 1900,
    "width" => 50,
    "url" => "https://d3frhmwvjke8bw.cloudfront.net/user/2/avatars/uploads/000/000/002/original/datasYohYl_tKQ?1595416219"
  }
}

```

## synthetic

Sometimes there is a need to export attribute or method defined on the ORM class, 
that means that there is no underlying DB column, and definition should be used only for the export.
Lets add expires_at attribute to Avatar model, it will mark the time of url signature expiration.

```ruby
class Avatar < UFile
  attribute :expires_at
end

swagger_schema :Avatar, description: 'Avatar attributes', required: [:id, :user_id, :meta] do
  #...
  property :expires_at, synthetic: true, type: 'string', format: :dateTime, description: 'Url expiration datetime'
end
```

As a result expires_at field will be added to the as_json output:
```"expires_at" => "2020-08-26T15:02:02.646Z",```


## virtual/injected

Lets imagine simple hierarchy of swagger schemas
```
FileMeta — ImageMeta
  \__ VideoMeta
```

Both VideoMeta and ImageMeta should have **width** and **height** attributes, and lets assume we want some only image specific attribute 
to be present on the ImageMeta, so they could not be aligned in a simple inheritance chain FileMeta — ImageMeta — VideoMeta. 
Solution is to use a virtual attribute in a FileMeta and use it wherever we want in the hierarchy. 
This attribute is just a helper to swagger schemas organization, otherwise hierarchy will transform into much more complicated tree.

Usage:
```ruby

class AttachmentMetaDoc
  include Swagger::Blocks

# jsonb field structure description:

  swagger_schema :FileMeta, required: [:size, :url], description: 'File base meta' do
    property :size, type: :integer, description: 'File size'
    property :url, type: :string, description: 'Signed url'
    property :mime, type: :string, description: 'Mime type'
  
    property :width, virtual: true, type: :integer, description: 'Width for picture'
    property :height, virtual: true, type: :integer, description: 'Height for picture'
  end


  inherit_schema :ImageMeta, :FileMeta, required: [:size, :url, :width, :height], description: 'image meta'  do
    property [:width, :height], inject: true
  end

  inherit_schema :VideoMeta, :FileMeta, required: [:size, :url, :width, :height, :duraiton], description: 'video meta'  do
    property [:width, :height], inject: true
    property :duration, type: :integer, description: 'video duration'
  end

end
```

# Problems and limitations

## Dual routing / double nesting (aka circular dependencies)

Usually this is pretty rare case, but still possible.
Circular dependencies should not be used or introduced, basically this problem could be solved using a different set of models in models chain.  

