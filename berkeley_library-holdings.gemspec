# frozen_string_literal: true

require_relative "lib/berkeley_library/holdings/version"

Gem::Specification.new do |spec|
  spec.name = "berkeley_library-holdings"
  spec.version = BerkeleyLibrary::Holdings::VERSION
  spec.authors = ["David Moles"]
  spec.email = ["dmoles@berkeley.edu"]

  spec.summary = "Holdings-related utilities for the UC Berkeley Library"
  spec.homepage = "https://github.com/BerkeleyLibrary/holdings"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

end