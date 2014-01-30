class AddExpiredToPointLineItems < ActiveRecord::Migration
  def change
    add_column :point_line_items, :expired, :boolean
  end
end
