class PointLineItem < ActiveRecord::Base
	belongs_to :user



	def self.users_having_items_on input_date
		date = input_date.to_date
		users = created_on(date).uniq.pluck(:id)
		User.find(users)
	end

	def self.points_available? user, input_date
		plis  = plis_after user, input_date
		available? plis
	end

	def self.points_until_expired user, input_date
	    plis = plis_up_to user, input_date
	    sum_until_expired plis
	end

	def self.redeem_points user, input_date
		plis = plis_after user, input_date
        redeem plis
	end



	private 
	  def self.created_on date
	  	 where(created_at: date..(date+1.day))
	  end

	  def self.latest_pli_of user, date
	  	created_on(date).where(user_id: user.id).order("created_at DESC").first
	  end

	  def self.plis_after user, input_date
	  	date = input_date.to_date
		current_pli = latest_pli_of user, date
	  	where("user_id = ? and created_at > ?", user.id, current_pli.created_at)
	  end

	  def self.plis_up_to user, input_date
	  	date = input_date.to_date
	    current_pli = latest_pli_of user, date
		where("user_id = ? and created_at <= ?", user.id, current_pli.created_at)
	  end

	  def self.available? plis
	  	available = true
	  	previous = plis.first
	  	plis.each do |pli|
	  		if  (previous.points > 0) && (pli.points < 0)
	  		  available = false
	  		  break
  		    else 
  		      previous = pli
	        end  
	    end
	    return available
	  end


	  def self.sum_until_expired plis
	  	sum = 0
	  	plis.order("created_at desc").find_each do |pli|
	  		break if pli.expired
    		sum += pli.points
    	end
    	return sum
	  end


	  def self.redeem plis
	  	points = 0
   		plis.each  do |pli|
   			break if pli.points > 0
   			points += pli.points
   		end
   		return points
	  end





end
