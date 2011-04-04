require 'spec_helper'

describe "places/index.html.erb" do
  before(:each) do
    assign(:places, [
      stub_model(Place,
        :title => "Title"
      ),
      stub_model(Place,
        :title => "Title"
      )
    ])
  end

  it "renders a list of places" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
