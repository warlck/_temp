class PointExpirer
	delegate :points_available?,
	         :points_until_expired,
	         :redeem_points, 
	         :expire_points, 
	         :latest_pli_of,
	         to: :PointLineItem


	def initialize user
		@user = user
	end

	def expire(input_date)
		date = input_date.to_date - 1.year
		latest_pli = latest_pli_of @user, date
		if points_available? @user, latest_pli.created_at
			points_to_expire = points_until_expired(@user, latest_pli.created_at). 
			                   + redeem_points(@user, latest_pli.created_at)
            expire_points @user, points_to_expire, latest_pli 
        end
	end
end