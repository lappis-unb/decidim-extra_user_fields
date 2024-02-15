# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is published from the admin panel.
    class PublishComponent < Decidim::Command
      # Public: Initializes the command.
      #
      # component - The component to publish.
      # current_user - the user performing the action
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Public: Publishes the Component.
      #
      # Broadcasts :ok if published, :invalid otherwise.
      def call
        publish_component_with_permissions
        publish_event
        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user

      def publish_component_with_permissions
        Decidim.traceability.perform_action!(
          :publish,
          component,
          current_user,
          visibility: "all"
        ) do
          update_permissions
          component.publish!
          component
        end
      end

      def publish_event
        Decidim::EventsManager.publish(
          event: "decidim.events.components.component_published",
          event_class: Decidim::ComponentPublishedEvent,
          resource: component,
          followers: component.participatory_space.followers
        )
      end

      def update_permissions
        actions = component&.manifest&.actions
        permissions = actions.inject({}) do |result, action|
          handlers_content = { "id_documents" => {} }
          serialized = {
            "authorization_handlers" => handlers_content
          }

          result.update(action => serialized)
        end
        component.update!(permissions: permissions)
        permissions
      end
    end
  end
end

