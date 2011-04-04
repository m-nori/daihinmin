require 'spec_helper'

describe "places/new.html.erb" do
  before(:each) do
    assign(:place, stub_model(Place,
      :title => "MyString"
    ).as_new_record)
  end

  it "renders new place form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => places_path, :method => "post" do
      assert_select "input#place_title", :name => "place[title]"
    end
  end
end
