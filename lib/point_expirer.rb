class PointExpirer
	delegate :users_having_items_on, 
	         :points_available?,
	         :points_unti_expired,
	         :redeem_points, 
	         :expire_points, 
	         to: :PointLineItem

	def expire(input_date)
		date = (input_date.to_date - 1.year)
		users = users_having_items_on date
		debugger
		users.each do |user| 
			if points_available? user, date
			   points_to_expire = points_unti_expired(user, date) + redeem_points(user, date)
			   #expire_points user, date, points_to_expire
			end
		end



	end
end