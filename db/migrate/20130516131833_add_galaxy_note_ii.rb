class AddGalaxyNoteIi < ActiveRecord::Migration
  def up
    Device.delete_all
    new_device = Device.new(dev_id:'328', dev_name:'Samsung Galaxy Note II')
    new_device.save
  end

  def down
  end
end
