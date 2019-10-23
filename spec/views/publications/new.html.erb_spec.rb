require 'rails_helper'

RSpec.describe "publications/new", type: :view do
  before(:each) do
    assign(:publication, Publication.new())
  end

  it "renders new publication form" do
    render

    assert_select "form[action=?][method=?]", publications_path, "post" do
    end
  end
end
