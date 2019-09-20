ActiveAdmin.register TargetScope do
  menu parent: 'Laws', priority: 4

  permit_params :name

  filter :name_contains, label: 'Name'

  controller do
    def destroy
      destroy_command = ::Command::Destroy::TargetScope.new(resource.object)

      message = if destroy_command.call
                  {notice: 'Successfully deleted selected TargetScope'}
                else
                  {alert: 'Could not delete selected TargetScope'}
                end

      redirect_to admin_target_scopes_path, message
    end
  end
end
