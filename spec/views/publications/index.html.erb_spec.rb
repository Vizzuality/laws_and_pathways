require 'rails_helper'

RSpec.describe "publications/index", type: :view do
  before(:each) do
    assign(:publications, [
      Publication.create!(),
      Publication.create!()
    ])
  end

  it "renders a list of publications" do
    render
  end
end
