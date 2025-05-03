require 'rails_helper'

RSpec.describe "rankings/edit", type: :view do
  let(:ranking) {
    Ranking.create!()
  }

  before(:each) do
    assign(:ranking, ranking)
  end

  it "renders the edit ranking form" do
    render

    assert_select "form[action=?][method=?]", ranking_path(ranking), "post" do
    end
  end
end
