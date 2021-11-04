# frozen_string_literal: true

require "rails"
require "modelix/config"
require "modelix/schema_loader"

class Modelix::Railtie < ::Rails::Railtie
  initializer "Modelix initializer" do |app|
    Modelix.config.logger = Rails.logger

    path = app.config.schemas_path
    Modelix.config.schemas_path = path

    schema_loader = Modelix::SchemaLoader.new
    schema_extensions = ["yml"]
    schema_dirs = {
      path.to_s => schema_extensions
    }

    schema_file_watcher = app.config.file_watcher.new([], schema_dirs) do
      schema_loader.load_schemas
    end
    app.reloaders << schema_file_watcher

    config.to_prepare { schema_file_watcher.execute }
  end
end
