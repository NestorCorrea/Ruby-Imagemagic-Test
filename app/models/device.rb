class Device < ActiveRecord::Base
  attr_accessible :back_image, :dev_id, :dev_name, :front_image

  def self.create_device_wraps(device, images)
    wrap_a = Array.new
    images.each do |current_image|

      created_images = WrapCreator.init_wrap(device, current_image)

      created_images.each do |current_image|
        wrap_a.push(current_image)
      end

    end
    wrap_a
  end
end
