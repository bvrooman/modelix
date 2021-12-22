# frozen_string_literal: true

require 'active_support/inflector'

require 'modelix/config'
require 'modelix/schema_loader'

RSpec.describe Modelix::SchemaLoader do
  subject(:schema_loader) { described_class.new }
  let(:path) { './spec/schemas' }

  before do
    Modelix.config.paths << path
  end

  describe 'load_schemas' do
    it 'loads the class objects defined by the schemas' do
      schema_loader.load_schemas
      expect('Test'.safe_constantize).to be_a Module
      expect('Test::TestSchema'.safe_constantize).to be_a Module
      expect('Test::TestSchema::Company'.safe_constantize).to be_a Class
      expect('Test::TestSchema::Employee'.safe_constantize).to be_a Class
    end
  end

  describe 'with custom types' do
    before do
      klass = Class.new do
        def self.name
          'string'
        end

        def self.parse(data)
          return '' if data.blank?

          "CUSTOM STRING #{data.to_s}"
        end
      end

      Modelix.config.register_type('string', klass)
    end

    describe 'load_schemas' do
      it 'loads the class objects defined by the schemas' do
        schema_loader.load_schemas
      end
    end
  end
end
