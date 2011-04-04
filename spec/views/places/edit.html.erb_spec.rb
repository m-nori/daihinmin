require 'spec_helper'

describe "places/edit.html.erb" do
  before(:each) do
    @place = assign(:place, stub_model(Place,
      :title => "MyString"
    ))
  end

  it "renders the edit place form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => places_path(@place), :method => "post" do
      assert_select "input#place_title", :name => "place[title]"
    end
  end
end
