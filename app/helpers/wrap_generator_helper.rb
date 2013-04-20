module WrapGeneratorHelper
  def generate_wrap(device, artwork)

    dropbox_path = "/Users/Nestor/Dropbox/"
    spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"

    ipad_front =    Image.read("#{spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/#{device.front_image}").first
    ipad_back =     Image.read("#{spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/#{device.back_image}").first
    spacer_white =  Image.new(50, 5000, Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF"))
    source_image =  Image.read("#{dropbox_path}wrap_generator/source_images/#{artwork.artwork_file_name}").first

    skin_front =  source_image.composite(ipad_front, 0, 0, Magick::OverCompositeOp)
    skin_back =   source_image.composite(ipad_back,  0, 0, Magick::OverCompositeOp)

    canvas = Image::new(ipad_front.columns + ipad_back.columns + spacer_white.columns, ipad_front.rows)
    canvas = canvas.composite(skin_front,     0,                                          0, Magick::OverCompositeOp)
    canvas = canvas.composite(spacer_white,   ipad_front.columns,                         0, Magick::OverCompositeOp)
    canvas = canvas.composite(skin_back,      ipad_front.columns + spacer_white.columns,  0, Magick::OverCompositeOp)

    canvas.write("/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/#{device.dev_id}-#{artwork.artwork_file_name}")

    # The response back to the controller, this will return the path of the iamge
    "#{device.dev_id}-#{artwork.artwork_file_name}"
  end


  require 'rexml/document'

  def parse_xml(dev_id)
    spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"
    logger.debug "THis is working for device id #{dev_id}"

    file = File.new( "#{spree_gelaskins_path}public/skinCreator/config/devices/#{dev_id}.xml")
    doc = REXML::Document.new file
    file.close

    # Stor the root of the xml
    root = doc.root

    elementsA = root.elements['sections']
    elementsA.each do |current_section|
      logger.debug("+++++++++++ #{current_section}")
    end
  end
end
