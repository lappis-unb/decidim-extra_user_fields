# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraUserFields::UserExportSerializer do
  subject { described_class.new(resource) }

  let(:resource) { create(:user, extended_data: registration_metadata) }
  # rubocop:disable Style/TrailingCommaInHashLiteral
  let(:registration_metadata) do
    {
      gender: gender,
      postal_code: postal_code,
      date_of_birth: date_of_birth,
      country: country,
      phone_number: phone_number,
      location: location,
      # Block ExtraUserFields ExtraUserFields
      document_id: document_id,
      # EndBlock
    }
  end
  # rubocop:enable Style/TrailingCommaInHashLiteral

  let(:gender) { "Other" }
  let(:postal_code) { "00000" }
  let(:date_of_birth) { "01/01/2000" }
  let(:country) { "Argentina" }
  let(:phone_number) { "0123456789" }
  let(:location) { "Cahors" }
  # Block ExtraUserFields RspecVar
  let(:document_id) { true }
  # EndBlock
  let(:serialized) { subject.serialize }

  describe "#serialize" do
    it "includes the id" do
      expect(serialized).to include(id: resource.id)
    end

    it "includes the gender" do
      expect(serialized).to include(gender: resource.extended_data["gender"])
    end

    it "includes the postal code" do
      expect(serialized).to include(postal_code: resource.extended_data["postal_code"])
    end

    it "includes the date of birth" do
      expect(serialized).to include(date_of_birth: resource.extended_data["date_of_birth"])
    end

    it "includes the country" do
      expect(serialized).to include(country: resource.extended_data["country"])
    end

    it "includes the phone number" do
      expect(serialized).to include(phone_number: resource.extended_data["phone_number"])
    end

    it "includes the location" do
      expect(serialized).to include(location: resource.extended_data["location"])
    end

    # Block ExtraUserFields IncludeExtraField
    it "includes the document_id" do
      expect(serialized).to include(document_id: resource.extended_data["document_id"])
    end
    
    # EndBlock
  end
end
