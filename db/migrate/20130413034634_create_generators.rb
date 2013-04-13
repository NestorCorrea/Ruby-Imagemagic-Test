class CreateGenerators < ActiveRecord::Migration
  def change
    create_table :generators do |t|
      t.string :dev_id
      t.string :dev_name

      t.timestamps
    end
  end
end
