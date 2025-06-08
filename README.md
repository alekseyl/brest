# B(etter)REST
Сybersquatting the name for a brest ( better REST ) gem.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add brest

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install brest

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alekseyl/brest. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alekseyl/brest/blob/master/CODE_OF_CONDUCT.md).

## TODO

- [ ] Major improvements
  - [ ] Proper naming ( basic method should be renamed from _sw suffixed methods, that is kinda sloppy )
  - [x] Allow nested selections in included model.
  - [x] Extract nested selection as standalone gem
  - [ ] Named pkeys ( currently :id is assumed and added all over the code :( ) 
  - [ ] Multiple schemas aka versions
  - [ ] Multiple ORM adapters.
    - [ ] Separate ActiveRecord adapter from preparation stuff
    - [ ] Introduce sequel adapter
    - [ ] Move activerecord to dev_dependencies and add check on any of supported ORMs presence
- [ ] DSL improvements
  - [ ] attrs enhancement ( currently jsonb/synthetic attribute naming stored 
          globally and hence might break when there is naming collision, see jsonb_attributes method ) 
  - [ ] Full DSL description with a example models relations
  - [ ] ActiveStorage helpers for preloading
  - [ ] inject_schema helper ( as a replacement for injectable attrs )
  - [x] Replace '$ref' => :Model, with type: :Model
  - [ ] Better api definitions helpers ( in body params + allowing schema to be mentioned in parameter function, 
        right now its a pretty messed up with the blank names params e.t.c. )
- [ ] Issues
  - [x] jsonb does not work without store model!
- [ ] Test coverage improvements (Cover with test all extensions related to synthetic attributes, jsonb models e.t.c.)
  - [x] Rethink data structures and relations
  - [x] jsonb
  - [x] includes_sw
  - [ ] injectable attributes
  - [x] select_sw
  - [x] select_sw nested
  - [ ] synthetic attributes
  - [x] property extended definition without '$ref'
- [ ] Examine schema with validators and ensure no swagger-ui hacks are used anymore, swagger UI is a messed up outdated thingy, use Postman instead.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Brest project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alekseyl/brest/blob/master/CODE_OF_CONDUCT.md).
