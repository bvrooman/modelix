# frozen_string_literal: true

require "active_support"

require "modelix/default_types"

RSpec.describe Modelix::DefaultTypes do
  describe "Date" do
    subject(:date_type) { Modelix::DefaultTypes::Date }

    describe "::parse" do
      it "returns a Date object when the string input is a valid date" do
        input = "2000-10-23"
        value = date_type.parse(input)
        expect(value).to eq Date.parse(input)
        expect(value).to be_a_kind_of Date
      end

      it "returns nil given nil input" do
        input = nil
        value = date_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given a blank string input" do
        input = ""
        value = date_type.parse(input)
        expect(value).to be nil
      end

      it "returns a Date object when the string input matches a custom format" do
        date_type.register_date_format("%Y.%m", /\A[0-9]{4}.[0-9]{2}\Z/)
        input = "2000.01"
        value = date_type.parse(input)
        expect(value).to eq Date.strptime(input, "%Y.%m")
        expect(value).to be_a_kind_of Date
      end

      it "raises an ArgumentError when the string input is not a recognized date format" do
        input = "2000_01_01"
        expect { date_type.parse(input) }.to raise_exception ArgumentError
      end
    end
  end

  describe "DateTime" do
    subject(:datetime_type) { Modelix::DefaultTypes::DateTime }

    describe "::parse" do
      it "returns a DateTime object when the string input is a valid datetime" do
        input = "2019-06-17 16:01:05 +0300"
        value = datetime_type.parse(input)
        expect(value).to eq DateTime.parse(input)
        expect(value).to be_a_kind_of DateTime
      end

      it "returns a DateTime object when the string input is a valid date" do
        input = "2001-02-03"
        value = datetime_type.parse(input)
        expect(value).to eq DateTime.parse(input)
        expect(value).to be_a_kind_of DateTime
      end

      it "returns nil given nil input" do
        input = nil
        value = datetime_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given a blank string input" do
        input = ""
        value = datetime_type.parse(input)
        expect(value).to be nil
      end

      it "raises an ArgumentError when the string input is not a recognized date format" do
        input = "2019-06 16:01:05 +0300"
        expect { datetime_type.parse(input) }.to raise_exception ArgumentError
      end
    end
  end

  describe "Integer" do
    subject(:integer_type) { Modelix::DefaultTypes::Integer }

    describe "::parse" do
      it "returns an Integer object when the string input is a positive integer" do
        input = "23"
        value = integer_type.parse(input)
        expect(value).to eq 23
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is '0'" do
        input = "0"
        value = integer_type.parse(input)
        expect(value).to eq 0
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is a negative integer" do
        input = "-74"
        value = integer_type.parse(input)
        expect(value).to eq(-74)
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is a positive integer with padding" do
        input = "0045"
        value = integer_type.parse(input)
        expect(value).to eq 45
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is a '0' with padding" do
        input = "000"
        value = integer_type.parse(input)
        expect(value).to eq 0
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is a negative integer with padding" do
        input = "-0045"
        value = integer_type.parse(input)
        expect(value).to eq(-45)
        expect(value).to be_a_kind_of(Integer)
      end

      it "raises an ArgumentError when the string input is a negative integer with improper padding" do
        input = "00-45"
        expect { integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "raises an ArgumentError when the string input is a float" do
        input = "0.56"
        expect { integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "raises an ArgumentError when the string input is non-numeric" do
        input = "seven"
        expect { integer_type.parse(input) }.to raise_exception ArgumentError

        input = "a67"
        expect { integer_type.parse(input) }.to raise_exception ArgumentError

        input = "67b"
        expect { integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "returns nil when the string input is 'NA'" do
        integer_type.nil_values << "NA"
        input = "NA"
        value = integer_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given nil input" do
        input = nil
        value = integer_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given a blank string input" do
        input = ""
        value = integer_type.parse(input)
        expect(value).to be nil
      end
    end
  end

  describe "PositiveInteger" do
    subject(:positive_integer_type) { Modelix::DefaultTypes::PositiveInteger }

    describe "::parse" do
      it "returns an Integer object when the string input is a positive integer" do
        input = "23"
        value = positive_integer_type.parse(input)
        expect(value).to eq 23
        expect(value).to be_a_kind_of(Integer)
      end

      it "returns an Integer object when the string input is '0'" do
        input = "0"
        value = positive_integer_type.parse(input)
        expect(value).to eq input.to_i
        expect(value).to be_a_kind_of(Integer)
      end

      it "raises an ArgumentError when the string input is a negative integer" do
        input = "-74"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "returns an Integer object when the string input is a positive integer with padding" do
        input = "0045"
        value = positive_integer_type.parse(input)
        expect(value).to eq 45
        expect(value).to be_a_kind_of(Integer)
      end

      it "raises an ArgumentError when the string input is a negative integer with padding" do
        input = "-0045"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "raises an ArgumentError when the string input is a float" do
        input = "0.56"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "raises an ArgumentError when the string input is non-numeric" do
        input = "seven"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError

        input = "a67"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError

        input = "67b"
        expect { positive_integer_type.parse(input) }.to raise_exception ArgumentError
      end

      it "returns nil when the string input is 'NA'" do
        positive_integer_type.nil_values << "NA"
        input = "NA"
        value = positive_integer_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given nil input" do
        input = nil
        value = positive_integer_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given a blank string input" do
        input = ""
        value = positive_integer_type.parse(input)
        expect(value).to be nil
      end
    end
  end

  describe "Float" do
    subject(:float_type) { Modelix::DefaultTypes::Float }

    describe "::parse" do
      it "returns a Float object when the string input is a valid integer" do
        input = "23"
        value = float_type.parse(input)
        expect(value).to eq input.to_f
        expect(value).to be_a_kind_of(Float)
      end

      it "returns a Float object when the string input is a valid float" do
        input = "0.56"
        value = float_type.parse(input)
        expect(value).to eq input.to_f
        expect(value).to be_a_kind_of(Float)
      end

      it "raises an ArgumentError when the string input is non-numeric" do
        input = "seven"
        expect { float_type.parse(input) }.to raise_exception ArgumentError
      end

      it "returns nil when the string input is 'NA'" do
        float_type.nil_values << "NA"
        input = "NA"
        value = float_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given nil input" do
        input = nil
        value = float_type.parse(input)
        expect(value).to be nil
      end

      it "returns nil given a blank string input" do
        input = ""
        value = float_type.parse(input)
        expect(value).to be nil
      end
    end
  end

  describe "String" do
    subject(:string_type) { Modelix::DefaultTypes::String }

    describe "::parse" do
      it "returns a String object when the string input is a valid string" do
        input = "Hello"
        value = string_type.parse(input)
        expect(value).to eq input
        expect(value).to be_a_kind_of(String)
      end

      it "returns a blank string given nil input" do
        input = nil
        value = string_type.parse(input)
        expect(value).to eq ""
      end

      it "returns a blank string given a blank string input" do
        input = ""
        value = string_type.parse(input)
        expect(value).to eq ""
      end
    end
  end
end
