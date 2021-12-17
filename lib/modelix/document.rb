# frozen_string_literal: true

module Modelix
  class Document
    attr_reader :attributes

    class Attribute
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end
    end

    def initialize
      @attributes = HashWithIndifferentAccess.new
    end

    def set(attribute)
      attributes[attribute.name] = attribute
    end
  end
end
