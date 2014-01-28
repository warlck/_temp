require 'spec_helper'

describe PointExpirer do
	 describe "#expire" do
	 	let(:point_expirer) { PointExpirer.new }

	 	it "is defined" do
	 		expect(point_expirer).to respond_to(:expire)
	 	end

	 	it "expects an argument" do
	 		expect{point_expirer.expire}.to raise_error(ArgumentError)
	 	end

	 end
end

