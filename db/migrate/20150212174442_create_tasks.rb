class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :item
      t.text :note
      t.boolean :done
      t.datetime :time

      t.timestamps
    end
  end
end
