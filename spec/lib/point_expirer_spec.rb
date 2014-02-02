require 'spec_helper'

describe PointExpirer do

    describe "initalizer" do
    	let(:user) { create(:user) }
    	it "is successfully initalized with  user" do
			expect{PointExpirer.new(user)}.not_to raise_error
	    end

    end
	
	 describe "#expire" do
	 	before(:each) do 
	 		@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			 create(:point_line_item, user: @adam,created_at: '01/01/2013', points: 25)
			 create(:point_line_item, user: @adam,created_at: '10/02/2013', points: 410)
			 create(:point_line_item, user: @adam,created_at: '15/02/2013', points: -250)
			 create(:point_line_item, user: @adam,created_at: '18/02/2013', points: 10)
			 @fifth = create(:point_line_item, user: @adam,created_at: '12/03/2013', points: 570)
			 create(:point_line_item, user: @adam,created_at: '15/04/2013', points: -500)
			 @seventh = create(:point_line_item, user: @adam,created_at: '27/06/2013', points: 130)

			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')
	 	end
	 	let(:point_expirer) { PointExpirer.new(@adam) }

	 	it "adds correct new entry to point_line_items table" do
			point_expirer.expire('13/03/2014')
	 		expect(PointLineItem.last.points).to eq -265 
	 	end

	 	it "when called on last items date given above" do
	 		point_expirer.expire('28/06/2014')
	 		expect(PointLineItem.last.points).to eq -395
	 	end

	 	it " when expire is called twice on different dates" do
	 		point_expirer.expire('13/03/2014')
	 		point_expirer.expire('28/06/2014')
	 		expect(PointLineItem.last.points).to eq -130
	 	end

	 	it " when expire is called  on different dates in reverse order" do
	 		point_expirer.expire('28/06/2014')
	 		point_expirer.expire('13/03/2014')
	 		expect(PointLineItem.last.points).to eq -395
	 	end

	 	it "when expire is called on the latest avaialble item" do
	 		last = create(:point_line_item, created_at: "28/06/2013", user: @adam)
	 		point_expirer.expire('28/06/2014')
	 		expect(PointLineItem.last.source).to eq "Points ##{@fifth.id}, ##{@seventh.id}, ##{last.id} expired"
	 	end

	 	it "when called for unavalable points" do
			expect{point_expirer.expire('15/02/2014')}.to change(PointLineItem, :count).by(0)
	 	end
	 	it "when called for expired points" do
	 		point_expirer.expire('13/03/2014')
			expect{point_expirer.expire('13/03/2014')}.to change(PointLineItem, :count).by(0)
	 	end

	 end
end

