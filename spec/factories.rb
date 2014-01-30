FactoryGirl.define do
	factory :point_line_item do
		points 100
		source "Make a purchase"
	end

	factory :user do
		name "Adam"
	end
end