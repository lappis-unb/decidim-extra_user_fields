# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module GovBrActionAuthorizer
      def initialize(authorization, options, component, resource)
        @authorization = authorization
        @options = options.deep_dup || {} # options hash is cloned to allow changes applied to it without risks
        @component = resource.try(:component) || component
        @resource = resource
        @organization = component.organization
      end

      def component_permitted_for_foreign_user?
        case @component.manifest_name
        when "proposals"
          if @component.settings["participatory_texts_enabled"]
            organization.participatory_texts_permitted_for_foreign_users?
          else
            organization.proposals_permitted_for_foreign_users?
          end
        when "surveys"
          organization.surveys_permitted_for_foreign_users?
        when "meetings"
          organization.meetings_permitted_for_foreign_users?
        else
          false
        end
      end

      def authorize
        if !authorization
          [:missing, { action: :authorize }]
        elsif authorization_expired?
          [:expired, { action: :authorize }]
        elsif !authorization.granted?
          [:pending, { action: :resume }]
        elsif unmatched_fields.any?
          [:unauthorized, { fields: unmatched_fields }]
        elsif missing_fields.any?
          [:incomplete, { fields: missing_fields, action: :reauthorize, cancel: true }]
        elsif !component_permitted_for_foreign_user?
          [:forbidden, {}]
        else
          [:ok, {}]
        end
      end

      protected

      attr_reader :organization
    end
  end
end
