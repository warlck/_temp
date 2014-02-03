class PointExpirer



	def initialize user
		@user = user
	end

	def expire(input_date)
		PointLineItem.expire(@user, input_date)
	end

	
end