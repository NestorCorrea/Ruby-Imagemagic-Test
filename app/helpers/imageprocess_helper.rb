require 'RMagick'
include Magick

module ImageprocessHelper
  def create_ipad
    ipad_front = Image.read('/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2FrontOverlay.png').first
    ipad_back = Image.read('/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2BackOverlay.png').first
    spacer_white =  Image.new(50, 5000, Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF"))
    source_image = Image.read('/Users/Nestor/Desktop/Generator/sample_images/climb.jpg').first

    skin_front =  source_image.composite(ipad_front, 0, 0, Magick::OverCompositeOp)
    skin_back =   source_image.composite(ipad_back, 0, 0, Magick::OverCompositeOp)

    canvas = Image::new(ipad_front.columns + ipad_back.columns + spacer_white.columns, ipad_front.rows)
    canvas = canvas.composite(skin_front,     0, 0, Magick::OverCompositeOp)
    canvas = canvas.composite(spacer_white,   ipad_front.columns, 0, Magick::OverCompositeOp)
    canvas = canvas.composite(skin_back,      ipad_front.columns-100 + spacer_white.columns, 0, Magick::OverCompositeOp)

    canvas.write('/Users/Nestor/Desktop/ipad_skin.jpg')
  end




  def create_all_ipads
    image_a = Dir.glob("/Users/Nestor/Desktop/Generator/sample_images/*.jpg")

    counter = -1

    image_a.each do |image|
      counter = counter +1

      # Create the wrap

      ipad_front = Image.read('/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2FrontOverlay.png').first
      ipad_back = Image.read('/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/iPad2BackOverlay.png').first
      spacer_white =  Image.new(50, 5000, Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF"))
      source_image = Image.read(image_a[counter]).first

      skin_front =  source_image.composite(ipad_front, 0, 0, Magick::OverCompositeOp)
      skin_back =   source_image.composite(ipad_back, 0, 0, Magick::OverCompositeOp)

      canvas = Image::new(ipad_front.columns + ipad_back.columns + spacer_white.columns, ipad_front.rows)
      canvas = canvas.composite(skin_front,     0, 0, Magick::OverCompositeOp)
      canvas = canvas.composite(spacer_white,   ipad_front.columns, 0, Magick::OverCompositeOp)
      canvas = canvas.composite(skin_back,      ipad_front.columns + spacer_white.columns, 0, Magick::OverCompositeOp)

      canvas.write('/Users/Nestor/Desktop/WrapExport/' + counter.to_s + '.jpg')


    end

  end


  def test_text_helper
    "This is now working fine"
  end
  def test_text_helper_print
    print  "This is now working fine"
  end


  def preview_image_display
    'assets/autobot.png'
  end

  def preview_image
      img_orig = Magick::Image.read('/Users/Nestor/Desktop/composite1.gif')
     # @response.headers["Content-type"] = img.mime_type

      img_orig.to_s
  end

  def red_image
# Create a 100x100 red image.
  end

  def g_image
      gold_fill = Magick::GradientFill.new(0, 0, 0, 0, "#f6e09a", "#cd9245")

      dst = Magick::Image.new(128, 128, gold_fill)
      src =  Magick::Image.new(128, 128, gold_fill)

      result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
      result.write('/Users/Nestor/Desktop/composite1.gif')
      result
      response '/Users/Nestor/Desktop/composite1.gif'
  end
end
