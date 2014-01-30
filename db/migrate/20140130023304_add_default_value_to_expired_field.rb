class AddDefaultValueToExpiredField < ActiveRecord::Migration
  def change
  	change_column :point_line_items, :expired, :boolean, default: false
  end
end
