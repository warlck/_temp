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

		it "ignores negative expired points" do
			create(:point_line_item, user: @adam, created_at: '21/01/2014 10:00', points: -20, expired: true)
			expect(PointLineItem.points_until_expired(@adam, '22/01/2014')).to eq 110
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

		it "ignores expired redeem point line items" do
			create(:point_line_item, user: @adam, created_at: "23/01/2014 10:00", points: -40, expired: true)
			expect(PointLineItem.redeem_points(@adam, '22/01/2014')).to eq -10
		end
	end

	describe ".latest_pli_of" do
		before(:each) do 
			@adam = create(:user, name: "Adam")
			@bella = create(:user, name: "Bella")
			@carl = create(:user, name: "Carl")
			@adams_zeroth_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 10:30', points: 20)
			@adams_first_item = create(:point_line_item, user: @adam, created_at: '20/01/2014 12:30', points: 100)
			@adams_second_item = create(:point_line_item, user: @adam,created_at: '21/01/2014', points: -10)
			
			bellas_item  = create(:point_line_item, user: @bella, created_at: '20/01/2014')
			carls_item = create(:point_line_item, user: @carl, created_at: '21/01/2014')
		end

		it "returns the  user's  last point line item that was created at given date if available" do
			expect(PointLineItem.latest_pli_of(@adam, '20/01/2014')).to eq @adams_first_item
		end

		it "returns the closest positive  point line item entry created  earlier dates if non available on given date" do
			expect(PointLineItem.latest_pli_of(@adam, '22/01/2014')).to eq @adams_first_item
		end
	end

	describe ".expire_points" do
		before(:each) do
			@user = create(:user)
			@points_to_expire = 20
			@pli = create(:point_line_item, user_id: @user.id)
		end

 
		it "adds new entry to point_line_items table" do
			expect{PointLineItem.expire_points(@user, @points_to_expire, @pli)}.to change(PointLineItem, :count).by(1)
		end

		it "adds correct source text" do
			PointLineItem.expire_points(@user, @points_to_expire, @pli)
			expect(PointLineItem.last.source).to eq "Points ##{@pli.id} expired"
		end

		it "changes expired field of pli to true" do
			PointLineItem.expire_points(@user, @points_to_expire, @pli)
			expect(@pli.reload.expired).to eq true		
		end
	end

  
end


