File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'berkeley_library/location/module_info'

Gem::Specification.new do |spec|
  spec.name = BerkeleyLibrary::Location::ModuleInfo::NAME
  spec.author = BerkeleyLibrary::Location::ModuleInfo::AUTHOR
  spec.email = BerkeleyLibrary::Location::ModuleInfo::AUTHOR_EMAIL
  spec.summary = BerkeleyLibrary::Location::ModuleInfo::SUMMARY
  spec.description = BerkeleyLibrary::Location::ModuleInfo::DESCRIPTION
  spec.license = BerkeleyLibrary::Location::ModuleInfo::LICENSE
  spec.version = BerkeleyLibrary::Location::ModuleInfo::VERSION
  spec.homepage = BerkeleyLibrary::Location::ModuleInfo::HOMEPAGE

  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir[
    'lib/**/*',
    '*.md'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'berkeley_library-logging', '~> 0.2'
  spec.add_dependency 'berkeley_library-util', '~> 0.1', '>= 0.1.9'
  spec.add_dependency 'jsonpath', '~> 0.5.8'
  spec.add_dependency 'marcel', '~> 1.0.2'
  spec.add_dependency 'nokogiri', '>= 1.19.1'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'rubyXL', '~> 3.4'

  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.75.0'
  spec.add_development_dependency 'rubocop-rake', '= 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '= 2.4.0'
  spec.add_development_dependency 'ruby-prof', '~> 1.7.1'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'vcr', '~> 6.1'
  spec.add_development_dependency 'webmock', '~> 3.12'
end
