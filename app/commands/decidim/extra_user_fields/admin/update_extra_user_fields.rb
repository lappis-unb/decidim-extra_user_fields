# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # A command with all the business logic when updating organization's extra user fields in signup form
      class UpdateExtraUserFields < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_extra_user_fields!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_extra_user_fields!
          Decidim.traceability.update!(
            form.current_organization,
            form.current_user,
            extra_user_fields: extra_user_fields
          )
        end

        def extra_user_fields
          {
            "enabled" => form.enabled.presence || false,
            "date_of_birth" => { "enabled" => form.date_of_birth.presence || false },
            "country" => { "enabled" => form.country.presence || false },
            "postal_code" => { "enabled" => form.postal_code.presence || false },
            "gender" => { "enabled" => form.gender.presence || false },
            "phone_number" => { "enabled" => form.phone_number.presence || false },
            "location" => { "enabled" => form.location.presence || false },
            # Block ExtraUserFields SaveFieldInConfig

            "selfie_image" => { "enabled" => form.selfie_image.present? },
            "document_image" => { "enabled" => form.document_image.present? },
            "document_number" => { "enabled" => form.document_number.present? },
            "document_valid" => { "enabled" => form.document_valid.present? },
            "document_type" => { "enabled" => form.document_type.present? },

            # EndBlock
            "permitted_components" => {
              "proposals" => form.proposals_permitted?,
              "participatory_texts" => form.participatory_texts_permitted?,
              "surveys" => form.surveys_permitted?,
              "meetings" => form.meetings_permitted?
            }
          }
        end
      end
    end
  end
end
