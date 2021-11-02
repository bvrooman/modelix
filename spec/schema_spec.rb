# frozen_string_literal: true

require "modelix/config"
require "modelix/schema"
require "modelix/schema_loader"

RSpec.describe Modelix::Schema do
  let(:schema_loader) { Modelix::SchemaLoader.new }
  let(:path) { "./spec/schemas" }
  let(:data) do
    {
      id: "123480369",
      name: "The ABC Company",
      employees: [
        {
          id: "1001",
          name: "John Smith",
          date_hired: "2021-08-01",
          salary: "50000.0"
        },
        {
          id: "1002",
          name: "Jane Doe",
          date_hired: "2021-09-01",
          salary: "60000.0"
        },
        {
          id: "1003",
          name: "Elon Musk",
          date_hired: "2021-10-01",
          salary: "30000.0"
        }
      ]
    }
  end
  let(:invalid_data) do
    {
      id: "NOT_A_NUMBER",
      name: "The ABC Company",
      employees: []
    }
  end

  before do
    Modelix.config.schemas_path = path
    schema_loader.load_schemas
  end

  describe "parse" do
    it "parses the top level object" do
      company = Test::TestSchema::Company.parse(data)

      expect(company.id).to eq(123_480_369)
      expect(company.name).to eq("The ABC Company")
      expect(company.employees).to be_an(Array)
      expect(company.employees).to all be_a(Test::TestSchema::Employee)
    end

    it "parses definition objects" do
      company = Test::TestSchema::Company.parse(data)

      expect(company.employees[0].id).to eq(1001)
      expect(company.employees[0].name).to eq("John Smith")
      expect(company.employees[0].date_hired).to eq(Date.parse("2021-08-01"))
      expect(company.employees[0].salary).to eq(50_000.0)

      expect(company.employees[1].id).to eq(1002)
      expect(company.employees[1].name).to eq("Jane Doe")
      expect(company.employees[1].date_hired).to eq(Date.parse("2021-09-01"))
      expect(company.employees[1].salary).to eq(60_000.0)

      expect(company.employees[2].id).to eq(1003)
      expect(company.employees[2].name).to eq("Elon Musk")
      expect(company.employees[2].date_hired).to eq(Date.parse("2021-10-01"))
      expect(company.employees[2].salary).to eq(30_000.0)
    end

    it "raises a ParseError when the data cannot be parsed according to the schema" do
      expect do
        Test::TestSchema::Company.parse(invalid_data)
      end.to raise_error Modelix::Parser::ParseError
    end
  end
end
