# frozen_string_literal: true

require 'rails'
require 'modelix/config'
require 'modelix/schema_loader'

module Modelix
  class Railtie < ::Rails::Railtie
    initializer 'Modelix initializer' do |app|
      Modelix.config.logger = Rails.logger

      paths = begin
        app.config.modelix_paths
      rescue StandardError
        []
      end
      Modelix.config.paths.push(*paths)

      schema_loader = Modelix::SchemaLoader.new
      schema_extensions = ['yml']
      schema_dirs = {}
      paths.each do |path|
        schema_dirs[path.to_s] = schema_extensions
      end

      schema_file_watcher = app.config.file_watcher.new([], schema_dirs) do
        schema_loader.load_schemas
      end
      app.reloaders << schema_file_watcher

      config.to_prepare { schema_file_watcher.execute }
    end
  end
end
