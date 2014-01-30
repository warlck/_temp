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

			expect(PointLineItem.users_having_items_on("20/01/2014")).to eq [adam]
		end
		
	end
  
end
