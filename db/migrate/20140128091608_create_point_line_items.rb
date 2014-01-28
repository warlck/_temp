class CreatePointLineItems < ActiveRecord::Migration
  def change
    create_table :point_line_items do |t|

      t.timestamps
    end
  end
end
