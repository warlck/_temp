class PointLineItem < ActiveRecord::Base
	belongs_to :user





	def self.users_having_items_on input_date
		date = input_date.to_date
		users = where(created_at: date..(date+1.day))
		
	end

end
