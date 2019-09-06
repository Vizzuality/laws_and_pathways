module ActiveAdminAddressableTabs
  # Creates tabs component which enables stimulus tabs_controller
  def tabs(&block)
    div 'data-controller': 'tabs' do
      super(&block)
    end
  end
end
