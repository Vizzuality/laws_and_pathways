module DiscardableController
  # Override default Active Admin destroy method using Discardable Model.
  # It sets discarded_at for entity and for its dependent resources.
  # Redirect to resource list with proper message
  def destroy
    entity_name = ActiveSupport::Inflector.singularize(controller_name).camelize
    entity_destroy_class = "::Command::Destroy::#{entity_name}".constantize
    destroy_command = entity_destroy_class.new(resource.object)

    success_message = {notice: "Successfully deleted selected #{entity_name}"}
    alert_message = {alert: "Could not delete selected #{entity_name}"}
    message = destroy_command.call ? success_message : alert_message

    redirect_to send("admin_#{controller_name}_path"), message
  end
end
