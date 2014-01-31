module Concerns
	module PointLineItemExpiring
		extend ActiveSupport::Concern
		
		module ClassMethods
			
			def points_available? user, input_date
				plis  = plis_after user, input_date
				available? plis
			end

			def points_until_expired user, input_date
			    plis = plis_up_to(user, input_date)
			    sum_until_expired plis
			end

			def redeem_points user, input_date
				plis = plis_after user, input_date
		        redeem plis
			end

			def latest_pli_of user, input_date
		   	  date = input_date.to_date
		      pli = created_on(user, date)
		      while pli.nil?
		        date -= 1.day
		        pli = created_on(user, date)
		      end
		      return pli
			end

			def expire_points user, points_to_expire, pli
				PointLineItem.create(user_id: user.id, points: -points_to_expire,
					source: "Points ##{pli.id} expired", expired: true)
				pli.update_attribute(:expired, true)
				expire_redeems user, pli
			end



			private 
			  def created_on user, date
			  	 where(created_at: date..(date+1.day)).where("points > 0 and user_id = ?", user.id).
			  	 order("created_at desc").first
			  end

			  def plis_after user, input_date
			  	date = input_date.to_date
				current_pli = latest_pli_of user, date
			  	where("user_id = ? and created_at > ?", user.id, current_pli.created_at)
			  end

			  def plis_up_to user, input_date
			  	date = input_date.to_date
			    current_pli = latest_pli_of user, date
				where("user_id = ? and created_at <= ?", user.id, current_pli.created_at)
			  end

			  def available? plis
			  	available = true
			  	previous = plis.first
			  	plis.each do |pli|
			  		if pli.points > 0 && pli.expired
			  			available = false
				  		break
				  	elsif pli.points < 0 && pli.expired
				  		nil # do nothing
				  	elsif (previous.points > 0) && (pli.points < 0)
				  		available = false
				  		break
			  		else 
			  		    previous = pli
				    end  
			    end
			    return available
			  end


			  def sum_until_expired plis
			  	sum = 0
			  	plis.order("created_at desc").each do |pli|
			  		break if pli.points > 0 && pli.expired
			  		if !(pli.points < 0 && pli.expired)
			    		sum += pli.points
			    	end
		    	end
		    	return sum
			  end


			  def redeem plis
			  	points = 0
		   		plis.each  do |pli|
		   			break if pli.points > 0
		   			unless pli.expired
		   			   points += pli.points
		   			end
		   		end
		   		return points
			  end

			  def expire_redeems user, pli
			  	plis = plis_after user, pli.created_at
			  	plis.each  do |pli|
		   		   break if pli.points > 0
				   pli.update_attribute(:expired, true)
		   		end
			  end
		end
		
		module InstanceMethods
			
		end
		
	end
end