class CreatePointLineItems < ActiveRecord::Migration
  def change
    create_table :point_line_items do |t|
      t.belongs_to  :user
      t.integer     :points
      t.string      :source
      t.datetime    :created_at
    end
  end
end
