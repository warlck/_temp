require 'spec_helper'

describe PointExpirer do
	 describe "#expire" do
	 	before(:each) do 
	 		@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			 create(:point_line_item, user: @adam,created_at: '01/01/2013', points: 25)
			 create(:point_line_item, user: @adam,created_at: '10/02/2013', points: 410)
			 create(:point_line_item, user: @adam,created_at: '15/02/2013', points: -250)
			 create(:point_line_item, user: @adam,created_at: '18/02/2013', points: 10)
			 create(:point_line_item, user: @adam,created_at: '12/03/2013', points: 570)
			 create(:point_line_item, user: @adam,created_at: '15/04/2013', points: -500)
			 create(:point_line_item, user: @adam,created_at: '27/06/2013', points: 130)

			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')
	 	end
	 	let(:point_expirer) { PointExpirer.new }

	 	it "adds new entry to point_line_items table" do
	 		#expect{point_expirer.expire("13/03/2014")}.to change(PointLineItem, :count).by(1)
	 		expect(point_expirer.expire("12/03/2014")).to eq 265
	 	end

	 end
end

