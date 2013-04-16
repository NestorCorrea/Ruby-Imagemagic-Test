class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :dev_id
      t.string :dev_name
      t.string :front_image
      t.string :back_image

      t.timestamps
    end
  end
end
