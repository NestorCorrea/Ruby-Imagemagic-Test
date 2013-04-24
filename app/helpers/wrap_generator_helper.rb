module WrapGeneratorHelper
  require 'rexml/document'
  # ======================
  # Device and artwork
  # ======================
  @device
  @artwork

  # ======================
  # Files
  # ======================
  @source_image

  # ======================
  # Imagemagic
  # ======================
  @skin_canvas
  @wrap_canvas
  @wrap_overlays_canvas
  @wrap_final

  # ======================
  # Skin Propeties
  # ======================
  @wrap_crop





  def generate_wrap(device, artwork)
    logger.debug "THis is working for device id #{@device.dev_id}"

    # Store the device and artwork image
    @device = device
    @artwork = artwork


    # Initial Variables
    dropbox_path = "/Users/Nestor/Dropbox/"
    spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"

    # Load XML
    @source_image =  Image.read("#{dropbox_path}wrap_generator/source_images/#{@artwork.artwork_file_name}").first

    # Load artwork file
    file = File.new( "#{spree_gelaskins_path}public/skinCreator/config/devices/#{@device.dev_id}.xml")
    doc = REXML::Document.new file
    file.close

    # Store the root of the xml
    root_xml = doc.root
    sections = root_xml.elements['sections']

    skinGen = root_xml.elements['skinGenerator']


    # Loop through the generator sections to store them
    skinGen.elements.each do |skin_element|
        logger.debug "Trace = #{skin_element}"
      if(skin_element.attributes['name'] == "skinart")
      #  logger.debug  "skin art = #{skin_element}"
      elsif(skin_element.attributes['name'] == "skinwrap")
        @wrap_crop = skin_element.elements['crop'].elements['cut']
      #  skin_elements.skin_wrap = skin_element
        #  logger.debug  "skin wrap = #{skin_element}"
      end
    end

    # Set the canvas to write the skin
    @skin_canvas =          Image::new(skinGen.attributes['width'].to_i, skinGen.attributes['height'].to_i)
    @wrap_canvas =          Image::new(skinGen.attributes['width'].to_i, skinGen.attributes['height'].to_i)
    @wrap_overlays_canvas = Image::new(skinGen.attributes['width'].to_i, skinGen.attributes['height'].to_i)
    @wrap_final =           Image::new(skinGen.attributes['width'].to_i, skinGen.attributes['height'].to_i)

    # Go through all the sections and generate the skin
    logger.debug("------ START ----------")

    # Create the images on the skin
    sections.elements.each do |current_section|
      generate_skin(current_section, 'skinart')
    end

    # Create the wraps
    sections.elements.each do |current_section|
      generate_skin(current_section, 'skinwrap')
      end

    sections.elements.each do |current_section|
      #generate_skin(current_section, 'place_overlay')
    end

    # Save the skins
    #@skin_canvas.write("/Users/Nestor/Desktop/export/skin_art.jpg")
    #@wrap_canvas.write("/Users/Nestor/Desktop/export/skin_wrap.jpg")
    #@wrap_overlays_canvas.write("/Users/Nestor/Desktop/export/skin_wrap_overlay.png")

    @wrap_final = @wrap_final.crop(
        @wrap_crop.elements['x'].text.to_f,
        @wrap_crop.elements['y'].text.to_f,
        @wrap_crop.elements['width'].text.to_f,
        @wrap_crop.elements['height'].text.to_f
    )
    @wrap_final.write("/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/#{@device.dev_id}-#{@artwork.artwork_file_name}")
    # The response back to the controller, this will return the path of the iamge
    "#{@device.dev_id}-#{@artwork.artwork_file_name}"
  end
end


# First step, generate the skin and wrap
def generate_skin(current_section, generatorType)
  # Skin Side
  if current_section.attributes['type'] == 'side'
    current_section.elements['sectionSkinConfig'].elements.each do |section_item|

      # Add to the skin art
      if section_item.attributes['name'] == 'skinart' && generatorType == 'skinart'
         add_section_to_skin(section_item)

      # Add to the wrap
      elsif section_item.attributes['name'] == 'skinwrap' && generatorType == 'skinwrap'
        # Add the overlay
        image_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/#{current_section.elements['elements'].elements['overlay'].text}"
        overlay_image =  Image.read("#{image_path}").first
        #@wrap_overlays_canvas = @wrap_overlays_canvas.composite(overlay_image, section_item.elements['x'].text.to_i, section_item.elements['y'].text.to_i, Magick::OverCompositeOp)


        # Paste the section of the skin art onto the wrap canvas
        paste_to_wrap(section_item)

        @wrap_canvas  = @wrap_canvas.composite(overlay_image, section_item.elements['x'].text.to_i, section_item.elements['y'].text.to_i, Magick::OverCompositeOp)

        cropped = @wrap_canvas.crop(section_item.elements['x'].text.to_i, section_item.elements['y'].text.to_i,overlay_image.columns, overlay_image.rows )
        @wrap_final = @wrap_final.composite(cropped, section_item.elements['x'].text.to_i, section_item.elements['y'].text.to_i, Magick::OverCompositeOp)
      elsif section_item.attributes['name'] == 'skinwrap' && generatorType == 'place_overlay'

      end
    end

  end
end


def paste_to_wrap (section_item)
  logger.debug("+++++++++++ Paste to wraps")

  # Process all the cuts
  section_item.elements['cuts'].elements.each do |current_cut|

    # Copy part of the image
    copy_image = @skin_canvas.crop(
         current_cut.elements['copy'].elements['x'].text.to_f,
         current_cut.elements['copy'].elements['y'].text.to_f,
         current_cut.elements['copy'].elements['width'].text.to_f,
         current_cut.elements['copy'].elements['height'].text.to_f)

    # Paste the image onto the wrap
    paste_x = current_cut.elements['paste'].elements['tl'].elements['x'].text.to_f
    paste_y = current_cut.elements['paste'].elements['tl'].elements['y'].text.to_f
    paste_h = current_cut.elements['paste'].elements['bl'].elements['y'].text.to_f - paste_y
    paste_w = current_cut.elements['paste'].elements['br'].elements['x'].text.to_f - paste_x

    copy_image = copy_image.resize(paste_w, paste_h)
    @wrap_canvas = @wrap_canvas.composite(copy_image,paste_x ,paste_y ,Magick::OverCompositeOp)
  end
end


def add_section_to_skin(section_item)
  logger.debug("+++++++++++ source_image W = #{@source_image.columns.to_s} x source_image H = #{@source_image.rows.to_s}")

  # Set the area parameters
  side_x =       section_item.elements['x'].text.to_f
  side_y =       section_item.elements['y'].text.to_f
  side_height =  section_item.elements['height'].text.to_i
  side_width =   section_item.elements['width'].text.to_i

  # Adjust the size of the image ot fit the side
  multiplier = 1.0

  # Try resizing to the height first
  multiplier = side_width / @source_image.columns.to_f

  if(@source_image.rows * multiplier < side_height)
    multiplier = side_height / @source_image.rows.to_f
  end

  # Size and position the art file on the side
  place_art = @source_image.resize(multiplier * @source_image.columns, multiplier * @source_image.rows)
  place_art = place_art.crop(0,0,side_width, side_height)

  # Place the sized art onto the canvas
  @skin_canvas =  @skin_canvas.composite(place_art, side_x, side_y  , Magick::OverCompositeOp)
end
