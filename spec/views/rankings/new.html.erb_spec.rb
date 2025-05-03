require 'rails_helper'

RSpec.describe "rankings/new", type: :view do
  before(:each) do
    assign(:ranking, Ranking.new())
  end

  it "renders new ranking form" do
    render

    assert_select "form[action=?][method=?]", rankings_path, "post" do
    end
  end
end
