class GAce2Us < ActiveRecord::Migration
  def up
    new_device = Device.new(dev_id:'292', dev_name:'Galaxy Ace 2  (US_Intl)')
    new_device.save
  end

  def down
  end
end
