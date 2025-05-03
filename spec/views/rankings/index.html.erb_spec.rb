require 'rails_helper'

RSpec.describe "rankings/index", type: :view do
  before(:each) do
    assign(:rankings, [
      Ranking.create!(),
      Ranking.create!()
    ])
  end

  it "renders a list of rankings" do
    render
    cell_selector = 'div>p'
  end
end
