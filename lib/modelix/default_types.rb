# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"

module Modelix::DefaultTypes
  class Date
    class Format
      attr_reader :template, :regex

      def initialize(template, regex)
        @template = template
        @regex = regex
      end
    end

    def self.name
      "date"
    end

    def self.register_date_format(template, regex)
      date_formats << Format.new(template, regex)
    end

    def self.date_formats
      @date_formats ||= []
    end

    def self.parse(data)
      return nil unless valid?(data)

      date_formats.each do |format|
        return ::Date.strptime(data, format.template) if data.to_s.match?(format.regex)
      end

      ::Date.parse(data)
    end

    def self.valid?(data)
      return false if data.blank?

      true
    end
  end

  class DateTime
    def self.name
      "datetime"
    end

    def self.parse(data)
      return nil unless valid?(data)

      ::DateTime.parse(data) if data.present?
    end

    def self.valid?(data)
      return false if data.blank?

      true
    end
  end

  class Integer
    def self.name
      "integer"
    end

    def self.nil_values
      @nil_values ||= []
    end

    def self.parse(data)
      return nil if data.blank?
      return nil if nil_values.include? data

      # Prevent invalid input from being cast to a integer
      raise ArgumentError, "Invalid #{name}: #{data}" unless valid?(data)

      data.to_i
    end

    def self.valid?(data)
      d = data.to_s
      return false if d.blank?

      # Return false if the string contains any character that is not a digit or '-'
      return false if /[^\d-]/.match?(d)

      # Return false if the string contains a '-' anywhere other than the start
      return false if [nil, 0].exclude?(d.index("-"))

      true
    end
  end

  class PositiveInteger < Integer
    def self.name
      "PositiveInteger"
    end

    def self.valid?(data)
      valid = super

      d = data.to_i
      valid &= d >= 0
      valid
    end
  end

  class Float
    def self.name
      "float"
    end

    def self.nil_values
      @nil_values ||= []
    end

    def self.parse(data)
      return nil if data.blank?
      return nil if nil_values.include? data

      # Prevent invalid input from being cast to a float
      raise ArgumentError, "Invalid #{name} #{data}" unless valid?(data)

      data.to_f
    end

    def self.valid?(data)
      d = data.to_s
      return false if d.blank?

      # Allow integer and float values
      return false unless [d.to_i.to_s, d.to_f.to_s].include? d.to_s

      true
    end
  end

  class String
    def self.name
      "string"
    end

    def self.parse(data)
      return "" if data.blank?

      data.to_s
    end
  end
end
