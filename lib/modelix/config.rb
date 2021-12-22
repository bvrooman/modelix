# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'logger'

module Modelix
  class Config
    @default_config = {
      logger: Logger.new($stdout),
      registered_types: {},
      paths: []
    }
    @allowed_config_keys = @default_config.keys

    class << self
      attr_reader :default_config, :allowed_config_keys
    end

    attr_reader :config

    def initialize
      @config = OpenStruct.new Config.default_config

      @config.instance_eval do
        def register_type(name, type)
          registered_types[name.to_s] = type
        end
      end
    end

    def configure(options)
      options.each do |key, value|
        @config.send("#{key.to_sym}=", value) if Config.allowed_config_keys.include? key.to_sym
      end
    end
  end

  def self.config
    @config ||= default_configuration
  end

  def self.reset_config
    @config = default_configuration
  end

  def self.default_configuration
    Config.new.config
  end
end
