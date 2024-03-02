# frozen_string_literal: true

require_relative "lib/brest/version"

Gem::Specification.new do |spec|
  spec.name = "brest"
  spec.version = Brest::VERSION
  spec.authors = ["alekseyl"]
  spec.email = ["leshchuk@gmail.com"]

  spec.summary = "B(etter)REST. Declarative REST-api + swagger documentation generator alongside with ORM optimizers. Sweeties and goodies for your REST-APIs"
  spec.description = "B(etter)REST. Declarative REST-api + swagger documentation generator alongside with ORM optimizers. Sweeties and goodies for your REST-APIs"
  spec.homepage = "https://github.com/alekseyl/brest"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alekseyl/brest"
  spec.metadata["changelog_uri"] = "https://github.com/alekseyl/brest/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "swagger-blocks", "~> 3.0"
  spec.add_dependency "activerecord", ">= 6.1"

  spec.add_development_dependency "mini-apivore"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest-rails"
  spec.add_development_dependency "rails", ">= 6.1"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "pg"

end
