module GeneratorsHelper

  def init_wraps
    @final_images = Array.new
    image_a = Dir.glob("#{@dropbox_path}wrap_generator/source_images/*.jpg")

    counter = -1

    image_a.each do |image|
      counter = counter +1

      # Create the wrap

      ipad_front =    Image.read("#{@spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2FrontOverlay.png").first
      ipad_back =     Image.read("#{@spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2BackOverlay.png").first
      spacer_white =  Image.new(50, 5000, Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF"))
      source_image =  Image.read(image_a[counter]).first

      skin_front =  source_image.composite(ipad_front, 0, 0, Magick::OverCompositeOp)
      skin_back =   source_image.composite(ipad_back,  0, 0, Magick::OverCompositeOp)

      canvas = Image::new(ipad_front.columns + ipad_back.columns + spacer_white.columns, ipad_front.rows)
      canvas = canvas.composite(skin_front,     0,                                          0, Magick::OverCompositeOp)
      canvas = canvas.composite(spacer_white,   ipad_front.columns,                         0, Magick::OverCompositeOp)
      canvas = canvas.composite(skin_back,      ipad_front.columns + spacer_white.columns,  0, Magick::OverCompositeOp)

      canvas.write      ("#{@dropbox_path}wrap_generator/wrap_export/" + counter.to_s + ".jpg")
      @final_images.push("#{@dropbox_path}wrap_generator/wrap_export/" + counter.to_s + ".jpg")
    end
  end
end