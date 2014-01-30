require 'spec_helper'

describe PointLineItem do
	it { should respond_to(:points)}
	it { should respond_to(:source)}
	it { should respond_to(:created_at)}
	

	it { should belong_to(:user)}

	it { should have_db_index(:user_id)}
	it { should have_db_index(:created_at)}


	describe "#expired" do
		let(:pli) { create(:point_line_item)}
		it " is defined as field" do
			expect(pli).to respond_to :expired
		end

		it "is false by default" do
			expect(pli.expired).to eq false
		end
	end

	describe ".users_having_items_on" do
		it "is defined" do
			expect(PointLineItem).to respond_to :users_having_items_on
		end

		it "returns users that have point line items on given date" do
			adam = create(:user, name: "Adam")
			bella = create(:user, name: "Bella")
			carl = create(:user, name: "Carl")
			adams_item = create(:point_line_item, user: adam, created_at: '20/01/2014')
			bellas_item  = create(:point_line_item, user: bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: carl, created_at: '21/01/2014')

			expect(PointLineItem.users_having_items_on("20/01/2014")).to eq [adam, bella]
		end

		
	end

	describe ".points_available?" do
		before(:each) do
			@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			adams_zeroth_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 10:30', points: 20)
			adams_first_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 12:30', points: 100)
			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')

		end

		it "returns true if points on certain date are available" do
			adams_second_item = create(:point_line_item, user: @adam,created_at: '21/01/2014', points: -10)
			adams_third_item = create(:point_line_item, user: @adam,created_at: '22/01/2014', points: 20)
			expect(PointLineItem.points_available?(@adam, '20/01/2014')).to eq true
		end

		it "returns false if points on certain date are not available" do
			adams_second_item = create(:point_line_item, user: @adam,created_at: '21/01/2014', points: 10)
			adams_third_item = create(:point_line_item, user: @adam,created_at: '22/01/2014', points: -20)
			expect(PointLineItem.points_available?(@adam, '20/01/2014')).to eq false
		end
	end

	describe ".points_until_expired" do
		before(:each) do 
			@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			adams_first_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 12:30', points: 100)
			adams_second_item = create(:point_line_item, user: @adam,created_at: '21/01/2014', points: -10)
			adams_third_item = create(:point_line_item, user: @adam,created_at: '22/01/2014', points: 20)

			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')

		end


		it "returns sum of all available points" do
			adams_zeroth_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 10:30', points: 20)
			expect(PointLineItem.points_until_expired(@adam, '20/01/2014')).to eq 120
		end

		it "does not include expired points" do
			adams_zeroth_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 10:30', points: 20, expired: true)
			expect(PointLineItem.points_until_expired(@adam, '20/01/2014')).to eq 100
		end
		
	end


	describe ".redeem_points" do
		before(:each) do 
			@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			adams_first_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 12:30', points: 100)
			adams_second_item = create(:point_line_item, user: @adam,created_at: '21/01/2014', points: -20)
			adams_third_item = create(:point_line_item, user: @adam,created_at: '22/01/2014', points: 20)
			adams_fourth_item = create(:point_line_item, user: @adam,created_at: '23/01/2014', points: -10)

			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')
		end

		it "redeems points given redeem point line items available after given date" do
			expect(PointLineItem.redeem_points(@adam, '20/01/2014')).to eq -20
		end
	end

  
end


