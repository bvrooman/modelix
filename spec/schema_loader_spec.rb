# frozen_string_literal: true

require "active_support/inflector"

require "modelix/config"
require "modelix/schema_loader"

RSpec.describe Modelix::SchemaLoader do
  subject(:schema_loader) { described_class.new }
  let(:path) { "./spec/schemas" }

  before do
    Modelix.config.schemas_path = path
  end

  describe "load_schemas" do
    it "loads the class objects defined by the schemas" do
      schema_loader.load_schemas
      expect("Test".safe_constantize).to be_a Module
      expect("Test::TestSchema".safe_constantize).to be_a Module
      expect("Test::TestSchema::Company".safe_constantize).to be_a Class
      expect("Test::TestSchema::Employee".safe_constantize).to be_a Class
    end
  end
end
