# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Boolean
        attribute :country, Boolean
        attribute :postal_code, Boolean
        attribute :date_of_birth, Boolean
        attribute :gender, Boolean
        attribute :phone_number, Boolean
        attribute :location, Boolean

        # Block ExtraUserFields Attributes
        attribute :selfie_image, Boolean
        attribute :document_image, Boolean
        attribute :document_number, Boolean
        attribute :document_valid, Boolean
        attribute :document_type, Boolean
        # EndBlock

        # Permitted components
        attribute :proposals_permitted, Boolean
        attribute :participatory_texts_permitted, Boolean
        attribute :surveys_permitted, Boolean
        attribute :meetings_permitted, Boolean
        # End Permitted components

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
          self.country = model.extra_user_fields.dig("country", "enabled")
          self.postal_code = model.extra_user_fields.dig("postal_code", "enabled")
          self.date_of_birth = model.extra_user_fields.dig("date_of_birth", "enabled")
          self.gender = model.extra_user_fields.dig("gender", "enabled")
          self.phone_number = model.extra_user_fields.dig("phone_number", "enabled")
          self.location = model.extra_user_fields.dig("location", "enabled")

          # Block ExtraUserFields MapModel
          self.selfie_image = model.extra_user_fields.dig("selfie_image", "enabled")
          self.document_image = model.extra_user_fields.dig("document_image", "enabled")
          self.document_number = model.extra_user_fields.dig("document_number", "enabled")
          self.document_valid = model.extra_user_fields.dig("document_valid", "enabled")
          self.document_type = model.extra_user_fields.dig("document_type", "enabled")
          # EndBlock

          # Permitted components
          self.proposals_permitted = model.proposals_permitted_for_foreign_users?
          self.participatory_texts_permitted = model.participatory_texts_permitted_for_foreign_users?
          self.surveys_permitted = model.surveys_permitted_for_foreign_users?
          self.meetings_permitted = model.meetings_permitted_for_foreign_users?
          # End Permitted components
        end
      end
    end
  end
end
