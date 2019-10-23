require 'rails_helper'

RSpec.describe "publications/edit", type: :view do
  before(:each) do
    @publication = assign(:publication, Publication.create!())
  end

  it "renders the edit publication form" do
    render

    assert_select "form[action=?][method=?]", publication_path(@publication), "post" do
    end
  end
end
