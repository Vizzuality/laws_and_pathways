module DiscardableController
  InvalidDestroyCommandError = Class.new(StandardError)

  # Override default Active Admin destroy method using Discardable Model.
  # It sets discarded_at for entity and for its dependent resources.
  # Redirect to resource list with proper message
  def destroy
    entity_name = ActiveSupport::Inflector.singularize(controller_name).camelize
    destroy_command = entity_destroy_class(entity_name).new(resource.object)

    success_message = {notice: "Successfully deleted selected #{entity_name}"}
    alert_message = {alert: "Could not delete selected #{entity_name}"}
    message = destroy_command.call ? success_message : alert_message

    redirect_to send("admin_#{controller_name}_path"), message
  end

  private

  def entity_destroy_class(entity_name)
    "::Command::Destroy::#{entity_name}".constantize
  rescue NameError
    raise InvalidDestroyCommandError, "Destroy command for #{entity_name} class does not exist"
  end
end
