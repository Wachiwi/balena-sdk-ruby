require 'bundler/setup'
require 'webmock/rspec'
require 'fakefs/spec_helpers'
require 'vcr'

require 'toml'

require 'resin'

CONFIG_FILE_PATH = File.join Dir.home, '.resin', 'resin.cfg'


VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def get_config_file
  File.open(CONFIG_FILE_PATH).read
end

def get_cfg_as_hash
  TOML.load_file(CONFIG_FILE_PATH)
end

