require 'singleton'
require 'toml'

require 'resin/util'

module Resin
  ##
  # Public: This class handles settings for Resin Python SDK.
  #
  # Example:
  #
  #   s = Resin::Settings.new
  #   # => <Resin::Settings:0x007fc9f4985a38 @config_file_path="..."  @settings={...}>
  class Settings
    include Singleton

    # Users home directory path.
    HOME_DIRECTORY = Dir.home
    # The section name in configuration file.
    CONFIG_SECTION = 'Settings'.freeze
    # The configuration file name.
    CONFIG_FILENAME = 'resin.cfg'.freeze

    # The default keys for the settings of the configuration.
    DEFAULT_SETTING_KEYS = Set.new %i[pine_endpoint api_endpoint api_version
                                    data_directory image_cache_time
                                    token_refresh_interval cache_directory timeout]

    # The resin data directory which contains the configuration file.
    DEFAULT_DATA_DIRECTORY = File.join(HOME_DIRECTORY, '.resin').freeze

    # The default settings for the configuration.
    DEFAULT_SETTINGS = {
        pine_endpoint: "https://api.resin.io/v#{Resin::API_VERSION}/",
        api_endpoint: 'https://api.resin.io/',
        api_version: "v#{Resin::API_VERSION}",
        data_directory: DEFAULT_DATA_DIRECTORY,
        image_cache_time: 1 * 1000 * 60 * 60 * 24 * 7,
        token_refresh_interval: 1 * 1000 * 60 * 60,
        timeout: 30 * 1000,
        cache_directory: File.join(DEFAULT_DATA_DIRECTORY, 'cache')
    }.freeze

    # private :read_settings

    ##
    # Public: Constructor of the Settings object
    def initialize
      @config_file_path = File.join(DEFAULT_SETTINGS[:data_directory], CONFIG_FILENAME)

      begin
        read_settings
        raise InvalidConfigurationError unless DEFAULT_SETTING_KEYS <= @settings.keys.to_set
      rescue Errno::ENOENT, InvalidConfigurationError => ex
        FileUtils.mv @config_file_path, "#{@config_file_path}.old" if File.exist? @config_file_path
        write_settings true
      end
    end

    ##
    # Private: Write settings to file.
    #
    # default - Boolean to flag if default values should be written.
    #
    # Examples
    #
    #   write_settings true
    #   # => true
    #
    #   write_settings
    #   # => true
    #
    # Returns true or false respectively if the write succeeded
    def write_settings(default = false)
      settings = {}

      if default
        settings[CONFIG_SECTION] = DEFAULT_SETTINGS
      else
        settings[CONFIG_SECTION] = @settings
      end

      FileUtils.mkdir_p DEFAULT_SETTINGS[:data_directory] unless Dir.exist? DEFAULT_SETTINGS[:data_directory]
      doc = TOML::Generator.new(settings).body
      File.write @config_file_path, doc
    end

    ##
    # Private: Read settings from file.
    #
    # **Examples:**
    #
    #   s = Resin::Settings.new
    #
    #   s.read_settings
    #   # => {:pine_endpoint=>"https://api.resin.io/v4/", :api_endpoint=>"https://api.resin.io/", ... }
    #
    # Returns the settings it has read as hash
    def read_settings
      cp = TOML.load_file(@config_file_path)[CONFIG_SECTION]
      Util.symbolize_keys(cp)
      @settings = DEFAULT_SETTINGS.merge cp
    end

    ##
    # Public: Get one or all settings information
    #
    # key (Optional) - The key that should get queried.
    #
    # Examples
    #
    #   get()
    #   # => {:pine_endpoint=>"https://api.resin.io/v4/", :api_endpoint=>"https://api.resin.io/", ... }
    #
    #   get('api_version')
    #   # => 'v4'
    #
    # Depending on the `key` argument it returns all settings for `key = nil` and the specific setting for `key != nil`.
    # If a non existent `key` was specified `nil` will get returned.
    def get(key = nil)
      read_settings
      if key.nil?
        @settings
      else
        @settings[(key.to_sym rescue key) || key]
      end
    end

    ##
    # Public: Check if the settings contains a given key.
    #
    # key - The check which existence should get checked.
    #
    # Example:
    #
    #   has_key('api_version')
    #   # => true
    #
    #   has_key('api_version1')
    #   # => false
    #
    # Returns true if the settings contain the key otherwise false.
    def has_key?(key)
      read_settings
      @settings.has_key? key
    end

    ##
    # Public: Set one or multiple keys of the settings
    #
    # To set a single key/value pair of the settings provide the options `key` and `val`.
    # If you want to set multiple values provide the option `opts` with a hash of settings.
    #
    # opts - The hash of options that should get set.
    # key - The single key that should get set.
    # value - The value of the key that should get set.
    #
    # Examples:
    #
    #   set()
    #   # => false
    #
    #   set(opts={api_version: 'v1', timeout: 10000})
    #   # => true
    #
    #   set('api_version', 'v1')
    #   # => true
    #
    # Returns true if the changes were made and false if the given combination of arguments was wrong
    def set(opts: nil, key: nil, value: nil)
      if not opts.nil?
        Util.symbolize_keys(opts)
        @settings.merge! opts
        write_settings
        true
      elsif not key.nil? and not value.nil?
        @settings[(key.to_sym rescue key) || key] = value
        write_settings
        true
      else
        false
      end
    end

    ##
    # Public: Remove a given key from the settings.
    #
    # If the removal was successful the changes are written to disk.
    #
    # key - The key that should get removed
    #
    # Examples:
    #
    #   remove('pine_endpoint')
    #   # => true
    #
    #   remove('pine_endpoint1')
    #   # => false
    #
    # Returns true if the removal was successful, otherwise it returns false.
    def remove(key)
      return false if key.nil?
      exists = !@settings.delete(key).nil?
      if exists
        write_settings
      end
      exists
    end

  end
end