require 'rails_helper'

RSpec.describe "publications/show", type: :view do
  before(:each) do
    @publication = assign(:publication, Publication.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
