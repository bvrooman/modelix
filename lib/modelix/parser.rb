# frozen_string_literal: true

require_relative "document"

class Modelix::Parser
  attr_reader :schema

  class ParseError < StandardError
    attr_reader :attribute, :data

    def initialize(attribute, data, error)
      @attribute = attribute
      @data = data
      @error = error

      message = "Modelix: Data Parser was unable to parse attribute #{attribute.name} (#{attribute.klass.name})"\
                " at #{attribute.path.join("->")}: #{error}"
      super(message)
    end
  end

  def initialize(schema)
    @schema = schema
  end

  def parse(raw)
    document = Modelix::Document.new
    schema.attributes.each do |attribute|
      value = attribute.parse(raw)
      attr = Modelix::Document::Attribute.new(attribute.name, value)
      document.set(attr)
    rescue ArgumentError, TypeError => e
      parser_error = ParseError.new(attribute, raw, e)
      Modelix.config.logger.error(parser_error)
      raise parser_error
    end
    document
  end
end
