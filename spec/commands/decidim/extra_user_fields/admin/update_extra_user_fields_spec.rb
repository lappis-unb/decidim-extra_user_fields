# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe UpdateExtraUserFields do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create :user, :admin, :confirmed, organization: organization }

        let(:extra_user_fields_enabled) { true }
        let(:postal_code) { true }
        let(:country) { true }
        let(:gender) { true }
        let(:date_of_birth) { true }
        let(:phone_number) { true }
        let(:location) { true }
        # Block ExtraUserFields RspecVar

        let(:document_image) { true }
        let(:document_number) { true }

        # EndBlock

        # rubocop:disable Style/TrailingCommaInHashLiteral
        let(:form_params) do
          {
            "enabled" => extra_user_fields_enabled,
            "postal_code" => postal_code,
            "country" => country,
            "gender" => gender,
            "date_of_birth" => date_of_birth,
            "phone_number" => phone_number,
            "location" => location,
            # Block ExtraUserFields ExtraUserFields

            "document_image" => document_image,
            "document_number" => document_number,

            # EndBlock
          }
        end
        # rubocop:enable Style/TrailingCommaInHashLiteral

        let(:form) do
          ExtraUserFieldsForm.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "call" do
          context "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't update the registration fields" do
              expect do
                command.call
                organization.reload
              end.not_to change(organization, :extra_user_fields)
            end
          end

          context "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the organization registration fields" do
              command.call
              organization.reload

              extra_user_fields = organization.extra_user_fields
              expect(extra_user_fields).to include("enabled" => true)
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("date_of_birth" => { "enabled" => true })
              expect(extra_user_fields).to include("gender" => { "enabled" => true })
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("phone_number" => { "enabled" => true })
              expect(extra_user_fields).to include("location" => { "enabled" => true })
              # Block ExtraUserFields InclusionSpec

              expect(extra_user_fields).to include("document_image" => { "enabled" => true })
              expect(extra_user_fields).to include("document_number" => { "enabled" => true })

              # EndBlock
            end
          end
        end
      end
    end
  end
end
