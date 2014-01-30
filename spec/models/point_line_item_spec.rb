require 'spec_helper'

describe PointLineItem do
	it { should respond_to(:points)}
	it { should respond_to(:source)}
	it { should respond_to(:created_at)}
	

	it { should belong_to(:user)}

	it { should have_db_index(:user_id)}
	it { should have_db_index(:created_at)}


	describe ".expired" do
		let(:pli) { create(:point_line_item)}
		it " is defined as field" do
			expect(pli).to respond_to :expired
		end

		it "is false by default" do
			expect(pli.expired).to eq false
		end
	end
  
end
