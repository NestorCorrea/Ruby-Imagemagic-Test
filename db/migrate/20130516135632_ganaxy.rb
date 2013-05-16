class Ganaxy < ActiveRecord::Migration
  def up
    new_device = Device.new(dev_id:'355', dev_name:'Samsung Galaxy S IV')
    new_device.save


    new_device = Device.new(dev_id:'309', dev_name:'Kindle Paperwhite')
    new_device.save
  end

  def down
  end
end
