# ------------------------------------------------------------
# Simplecov

require 'colorize'
require 'simplecov' if ENV['COVERAGE']

# ------------------------------------------------------------
# RSpec

require 'webmock/rspec'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after { WebMock.allow_net_connect! }
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# ------------------------------------------------------------
# Code under test

require 'berkeley_library/location'
require 'berkeley_library/util/xlsx'
