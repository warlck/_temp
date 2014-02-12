module Concerns
	module PointLineItemExpiring
		extend ActiveSupport::Concern
		
		module ClassMethods
			
			def points_available? pli
				plis  = plis_after pli
				available? plis
			end

			def points_until_expired user, input_date
			    plis = plis_up_to(user, input_date)
			    sum_until_expired plis
			end

			def redeem_points pli
				plis = plis_after pli
		        redeem plis
			end

			def latest_pli_of user, input_date
		   	  date = input_date.to_date
		      where("created_at < ?", date + 1.day).
			  where("points > 0 and user_id = ? ", user.id).
			  order("created_at desc").first
			end

			def expire(user, input_date)
				date = input_date.to_date - 1.year
				latest_pli = latest_pli_of user, date
				if !latest_pli.expired && points_available?(latest_pli) 
					points_to_expire = points_until_expired(user, latest_pli.created_at). 
					                   + redeem_points(latest_pli)
		            expire_points user, points_to_expire, latest_pli 
		        end
			end
	  	    
	  	    def expire_points user, points_to_expire, pli
			 	PointLineItem.create(user_id: user.id, points: -points_to_expire,
					source: expire_source(user, pli), expired: true)
				pli.update_attribute(:expired, true)
				expire_redeems user, pli
			end

			private 


			  def plis_after pli
			  	where("user_id = ? and created_at > ?", pli.user_id, pli.created_at)
			  end

			  def plis_up_to user, input_date
			    current_pli = latest_pli_of user, input_date
				where("user_id = ? and created_at <= ?", user.id, current_pli.created_at).
				order("created_at desc")
			  end

			  def available? plis
			  	previous = plis.first
			  	plis.each do |pli|
			  		return false unless decide_availability previous, pli, binding
			    end
			    return true
			  end


			  def decide_availability  previous, pli, bndg
			  	 if pli.points < 0 && pli.expired
			  		return true # do nothing
			  	 elsif (previous.points > 0 && pli.points < 0) ||
			  		   (pli.points > 0 && pli.expired)
			  		return false
		  		 else 
		  		    eval "previous = pli", bndg
			     end     
			  end 

			  def sum_until_expired plis
			  	sum = 0
			  	plis.each do |pli|
			  		break unless can_add_to pli, binding
		    	end
		    	return sum
			  end

			  def can_add_to pli, bndg
			  	 if pli.points > 0 && pli.expired
			  		false
			  	 elsif !(pli.points < 0 && pli.expired)
			    	eval "sum += pli.points", bndg
			     else
			     	true
			     end
			  end

			  def redeem plis
			  	points = 0
		   		plis.each  do |pli|
		   			break unless can_redeem pli, binding
		   		end
		   		return points
			  end

			  def can_redeem pli, bndg
			  	 if pli.points > 0
			  	 	false
			  	 elsif !pli.expired
			  	 	eval "points += pli.points", bndg
			  	 else
			  	 	true
			  	 end	 
			  end


			  def expire_redeems user, pli
			  	plis = plis_after pli
			  	plis.each  do |pli|
		   		   break if pli.points > 0
				   pli.update_attribute(:expired, true)
		   		end
			  end

			  def expire_source user, pli
			  	plis = plis_up_to(user, pli.created_at)
			  	ids  = expired_id_list user, plis
			  	generate_source_text ids
			  end

			  def expired_id_list user, plis
			  	ids = []
			  	plis.each do |local_pli|
			  		break unless add_to_id_list user,  ids, local_pli
			  	end
			  	return ids
			  end


			  def add_to_id_list  user, ids, local_pli
			  	current_pli = latest_pli_of user, local_pli.created_at
		  		if current_pli.expired || !points_available?(local_pli) 
		  			false
		  		else
		  			ids.unshift current_pli.id unless ids.include?(current_pli.id)
		  		end  	
			  end


			  def generate_source_text ids
			  	 source = "Points "
			  	 ids.each_with_index do |id ,index|
			  	 	source += ", " unless index == 0
			  	 	source += "##{id}"
			  	 end
			  	 source += " expired"
			  end
		end
		
		module InstanceMethods
			
		end
		
	end
end