class AddIpodClassic < ActiveRecord::Migration
  def up
    new_device = Device.new(dev_id:'19', dev_name:'iPod Classic')
    new_device.save
  end

  def down
  end
end
