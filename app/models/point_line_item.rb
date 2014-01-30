class PointLineItem < ActiveRecord::Base
	include Concerns::PointLineItemExpiring

	belongs_to :user


end
