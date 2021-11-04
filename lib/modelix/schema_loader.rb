# frozen_string_literal: true

require "yaml"

require_relative "default_types"
require_relative "schema"

class Modelix::SchemaLoader
  class << self
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def extract_fully_qualified_paths(path)
      subpaths = Dir.entries(path)
                    .reject { |entry| %w[. ..].include? entry }
                    .select { |entry| File.directory? File.join(path, entry) } || []

      files = Dir.entries(path)
                 .reject { |entry| %w[. ..].include? entry }
                 .reject { |entry| File.directory? File.join(path, entry) } || []

      files.map! { |file| File.join(path, file) }

      subpaths.each do |subpath|
        files.push(*extract_fully_qualified_paths(File.join(path, subpath)))
      end

      files
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def schema_files(path)
    files = Modelix::SchemaLoader.extract_fully_qualified_paths(path)
    files.select! do |file|
      # Process files only ending with the modelix suffix
      regex = /.*_schema(?:.\d+.\d+.\d+)?.yml/
      file.match? regex
    end
    files
  end

  def schema_parser
    @schema_parser ||= Modelix::Schema::Parser.new
  end

  def default_context
    @default_context ||= begin
      context = {}
      context[Modelix::DefaultTypes::Boolean.name] = Modelix::DefaultTypes::Boolean
      context[Modelix::DefaultTypes::Date.name] = Modelix::DefaultTypes::Date
      context[Modelix::DefaultTypes::DateTime.name] = Modelix::DefaultTypes::DateTime
      context[Modelix::DefaultTypes::Integer.name] = Modelix::DefaultTypes::Integer
      context[Modelix::DefaultTypes::PositiveInteger.name] = Modelix::DefaultTypes::PositiveInteger
      context[Modelix::DefaultTypes::Float.name] = Modelix::DefaultTypes::Float
      context[Modelix::DefaultTypes::String.name] = Modelix::DefaultTypes::String
      context
    end
  end

  def initialize
    # Define integer values that should be treated as nil
    Modelix::DefaultTypes::Integer.nil_values << "NA"

    # Define positive integer values that should be treated as nil
    Modelix::DefaultTypes::PositiveInteger.nil_values << "NA"

    # Define float values that should be treated as nil
    Modelix::DefaultTypes::Float.nil_values << "NA"
  end

  def load_schemas
    context = {}
    context.merge!(default_context)

    path = Modelix.config.schemas_path
    schema_files = schema_files(path)
    schema_files.each do |file|
      path = File.expand_path(file)
      Modelix.config.logger.info("Modelix: Parsing schema file #{path}...")
      namespace = schema_parser.namespace(path)
      data = HashWithIndifferentAccess.new(YAML.load_file(path))
      schema_parser.parse_schema(namespace, data, context)
    end
  end
end
