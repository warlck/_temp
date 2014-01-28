class User < ActiveRecord::Base

  validates :name, presence: true
  has_many :point_line_items

end