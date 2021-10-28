# frozen_string_literal: true

require_relative '../modelix'
require_relative 'parser'

class Modelix::Schema
  class Parser
    def schemas_path
      Modelix.config.schemas_path
    end

    # Extract a namespace from a modelix file's filesystem path
    #
    # Given a fully qualified path, this will return a namespace (module or class) that matches the folder structure of
    # the path. The hierarchy of folders is mapped directly to a hierarchy of namespaces. A namespace is nested inside
    # its parent namespace, with the top-level namespace being the default Object.
    #
    # If the folder hierarchy does not match an existing namespace, named modules will be created to accommodate the new
    # hierarchy.
    #
    #   file = "/data/schemas/entities/tc/default.yml"
    #   parser.namespace(file) #=> Entities::Tc
    #
    def namespace(file)
      regex = /#{schemas_path}(?<path>.+)/
      schema_path = file.match(regex)[:path]
      directory = File.dirname(schema_path)
      namespace = Object
      module_names = directory.split('/').select(&:present?)
      module_names.each do |module_name|
        namespace_name = module_name.camelcase.to_s
        namespace = find_or_create_namespace(namespace_name, parent: namespace)
      end
      namespace
    end

    def define_schema(name, properties, namespace, context)
      schema = Modelix::Schema.new(name)

      properties.each do |property|
        property_name = property[:name]
        path = property[:path]
        klass = nil
        array = false

        if property.key?(:type)
          klass_name = property[:type]
          if context.key?(klass_name)
            # Default classes without namespace
            klass = context.fetch(klass_name)
          else
            # Namespaced classes
            key = "#{namespace}::#{klass_name}"
            klass = context.fetch(key)
          end
        end

        array = property[:array] if property.key?(:array)

        attribute = Modelix::Schema::Attribute.new(name: property_name, path: path, klass: klass, array: array)
        schema.attributes << attribute
      end

      schema
    end

    def define_class(name, properties, namespace, context)
      schema_parser = self
      params = properties.pluck(:name).map(&:to_sym)

      klass = Class.new do
        define_singleton_method :name do
          name
        end

        define_singleton_method :properties do
          params
        end

        define_singleton_method :parse do |data|
          return nil if data.nil?

          document = data_parser.parse(data)
          attributes = document.attributes
          values = attributes.map { |_k, attribute| attribute.value }
          new(*values)
        end

        define_singleton_method :data_parser do
          @data_parser ||= begin
            schema = schema_parser.define_schema(name, properties, namespace, context)
            parser = Modelix::Parser.new(schema)
            parser
          end
        end

        params.each { |param| attr_reader param }

        define_method :initialize do |*args|
          params_to_args = params.zip(args)
          params_to_args.each do |param, arg|
            instance_variable_set("@#{param}", arg)
          end
        end

        define_method :attributes do
          instance_values
        end
      end

      # Eager load data parser to define related schemas
      klass.data_parser

      key = "#{namespace}::#{name}"
      context[key] = klass
      klass
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def parse_schema(namespace, data, context)
      schema = data[:schema]
      if schema.present?
        namespace = find_or_create_namespace(schema, parent: namespace)

        version = data[:version]
        if version.present?
          version_number = "V_#{version.to_s.tr(".", "_")}"
          namespace = find_or_create_namespace(version_number, parent: namespace)
        end
      end

      definitions = data[:definitions]
      if definitions.present? && definitions.is_a?(Array)
        definitions.each do |definition|
          parse_schema(namespace, definition, context)
        end
      end

      klass_name = data[:class]
      properties = data[:properties] || []
      klass = define_class(klass_name, properties, namespace, context)
      namespace.instance_eval { remove_const(klass_name) } if namespace.const_defined?(klass_name)
      namespace.const_set(klass_name, klass)
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    def find_or_create_namespace(namespace, parent: Object)
      # Attempt to load the namespace in the event it already exists to prevent overwriting it
      full_namespace = "#{parent}::#{namespace}"
      full_namespace.safe_constantize

      if parent.const_defined?(namespace)
        parent.const_get(namespace)
      else
        parent.const_set(namespace, Module.new)
      end
    end
  end

  class Attribute
    attr_reader :name, :path, :klass

    def initialize(name:, path:, klass: nil, array: false)
      @name = name
      @path = path.map(&:to_sym)
      @klass = klass
      @array = array
    end

    def array?
      @array
    end

    def parse(data)
      return nil if data.nil?

      value = data.dig(*path).dup

      if klass.present?
        if value.is_a?(Array)
          value.map! do |v|
            klass.parse(v)
          end
        else
          value = klass.parse(value)
        end
      end

      # If the value is expected to be returned as an array, wrap the value in a new array.
      # A value that is already an array will be unchanged.
      value = Array(value) if array?

      value
    end
  end

  attr_reader :name, :attributes

  def initialize(name)
    @name = name
    @attributes = []
  end
end
