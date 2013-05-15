class WrapCreator < ActiveRecord::Base
  # attr_accessible :title, :body
  require 'json'


  # ======================================
  # Instance Variables
  # ======================================
  # Store the device and artwork image
  @device
  @artwork

  @device_template
  @skin_generator
  @side_images
  @sections
  @send_image_array

  # ---- Skin Propeties ----
  @wrap_crop
  @wrap_overlays
  @current_section

  # Initial Variables
  @dropbox_path = "/Users/Nestor/Dropbox/"
  @spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"
  @layout_asset_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/"
  @preview_asset_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/previewAssets/"
  @wrap_export_path = "/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/"


  # ======================================
  # Initilizer
  # ======================================
  def self.init_wrap(current_device, current_image)
    @send_image_array = Array.new
    @device = current_device
    @artwork = current_image
    @side_images = Hash.new

    # Load XML
    @source_image =  Image.read("#{@dropbox_path}wrap_generator/source_images/#{@artwork.artwork_file_name}").first

    # Load artwork file
    file = File.new( "#{@spree_gelaskins_path}public/skinCreator/config/devices/#{@device.dev_id}.xml")
    doc_xml = REXML::Document.new file
    file.close

    @sections = doc_xml.root.elements['sections']
    @skinGen = doc_xml.root.elements['skinGenerator']


    # Loop through the generator sections to store them
    @skinGen.elements.each do |skin_element|
      logger.debug "Trace = #{skin_element}"
      if(skin_element.attributes['name'] == "skinart")
        #  logger.debug  "skin art = #{skin_element}"
      elsif(skin_element.attributes['name'] == "skinwrap")
        @wrap_crop = skin_element.elements['crop'].elements['cut']
        @wrap_overlays = skin_element.elements['overlayAssets']
      end
    end

    # Set the canvas to write the skin
    @wrap_final =  Image::new(@skinGen.attributes['width'].to_i, @skinGen.attributes['height'].to_i)

    mask_test

    create_skin_art

    create_wrap_temp

    create_wrap_final

    @send_image_array
  end


  # ======================================
  # 1 Skin Art File
  # ======================================
  def self.create_skin_art
    # Go through all the sections and generate the skin
    logger.debug("------ START ----------")
    @skin_art_canvas = Image::new(@skinGen.attributes['width'].to_i, @skinGen.attributes['height'].to_i)

    # Create the images on the skin
    @sections.elements.each do |current_section|
      if current_section.attributes['type'] == 'side'
        current_section.elements['sectionSkinConfig'].elements.each do |section_item|
          if section_item.attributes["name"] == 'skinart'
            logger.debug section_item
            @side_images[current_section.attributes['name']] = add_to_skin_art(section_item)
          end
        end
      end
    end
    save_image(@skin_art_canvas, "skin_art.jpg")
  end

  def self.add_to_skin_art(section_item)
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
    place_art = @source_image.resize(
            multiplier * @source_image.columns,
            multiplier * @source_image.rows)

    # Get the boundig Box
    image_center_x = place_art.columns * 0.5
    image_center_y = place_art.rows    * 0.5

    stage_center_x = side_width / 2
    stage_center_y = side_height / 2

    new_x = image_center_x - stage_center_x
    new_y = image_center_y - stage_center_y

    if new_x < 0
      new_x = 0
    end

    if (new_x + place_art.columns) < side_width
      new_x = place_art.columns - side_width
    end

    if new_y < 0
      new_y = 0
    end

    if (new_y + place_art.rows) < side_height
      new_y = place_art.rows - side_height
    end

    place_art = place_art.crop(new_x, new_y, side_width, side_height)

    logger.debug 'Adding to the skin art file'
    # Place the sized art onto the canvas
    @skin_art_canvas =  @skin_art_canvas.composite(
            place_art,
            side_x,
            side_y  ,
            Magick::OverCompositeOp)

    place_art
  end


  # ======================================
  # 2 Wrap Temp
  # ======================================
  def self.create_wrap_temp
    @wrap_temp = Image::new(@skinGen.attributes['width'].to_i, @skinGen.attributes['height'].to_i)

    # Go through all the sections and generate the skin
    logger.debug("------ Creating Wrap Temp ----------")

    # Create the images on the skin
    @sections.elements.each do |current_section|
      if current_section.attributes['type'] == 'side'
        current_section.elements['sectionSkinConfig'].elements.each do |section_item|
          if section_item.attributes["name"] == 'skinwrap'
            section_item.elements['cuts'].elements.each do |current_cut|
              # Copy part of the image
              copy_image = @skin_art_canvas.crop(
                      current_cut.elements['copy'].elements['x'].text.to_f,
                      current_cut.elements['copy'].elements['y'].text.to_f,
                      current_cut.elements['copy'].elements['width'].text.to_f,
                      current_cut.elements['copy'].elements['height'].text.to_f)

              # Paste the image onto the wrap
              if current_cut.elements['paste'].elements['tl']
                paste_x = current_cut.elements['paste'].elements['tl'].elements['x'].text.to_f
                paste_y = current_cut.elements['paste'].elements['tl'].elements['y'].text.to_f
                paste_h = current_cut.elements['paste'].elements['bl'].elements['y'].text.to_f - paste_y
                paste_w = current_cut.elements['paste'].elements['br'].elements['x'].text.to_f - paste_x
              else
                paste_x = current_cut.elements['paste'].elements['x'].text.to_f
                paste_y = current_cut.elements['paste'].elements['y'].text.to_f
                paste_h = current_cut.elements['paste'].elements['height'].text.to_f
                paste_w = current_cut.elements['paste'].elements['width'].text.to_f
              end

              copy_image = copy_image.crop(
                      section_item.elements['x'].text.to_f,
                      section_item.elements['y'].text.to_f,
                      section_item.elements['width'].text.to_f,
                      section_item.elements['height'].text.to_f)

              copy_image = copy_image.resize(paste_w, paste_h)
              save_image(copy_image,"wrap_Side_Copy_#{current_section.attributes['name']}.png")

              @wrap_temp = @wrap_temp.composite(copy_image,paste_x ,paste_y ,Magick::OverCompositeOp)
            end
          end
        end
      end
    end

    save_image(@wrap_temp, "wrap_temp.jpg")
  end


  # ======================================
  # 3 Wrap Final
  # ======================================
  def self.create_wrap_final
    @wrap_final = Image::new(@skinGen.attributes['width'].to_i, @skinGen.attributes['height'].to_i)

    # Go through all the sections and generate the skin
    logger.debug("------ Creating Wrap Temp ----------")

    # Create the images on the skin
    @sections.elements.each do |current_section|
      if current_section.attributes['type'] == 'side'
        current_section.elements['sectionSkinConfig'].elements.each do |section_item|
          if section_item.attributes["name"] == 'skinwrap'

            logger.debug("------ Skin Wrap Section ----------")

            copy_image = @wrap_temp.crop(
                    section_item.elements['x'].text.to_f,
                    section_item.elements['y'].text.to_f,
                    section_item.elements['width'].text.to_f,
                    section_item.elements['height'].text.to_f)


            if current_section.elements['elements'].elements['overlayMask']
              logger.debug("Overlay Found at #{@layout_asset_path}#{current_section.elements['elements'].elements['overlayMask'].text}")
              mask = Image.read("#{@layout_asset_path}#{current_section.elements['elements'].elements['overlayMask'].text}").first
              mask = mask.resize copy_image.columns, copy_image.rows

              mask_canvas = Image::new(copy_image.columns, copy_image.rows){self.background_color = "white"}
              mask_canvas.background_color = "none"
              mask = mask_canvas.composite(mask, Magick::CenterGravity, Magick::OverCompositeOp)

              copy_image.add_compose_mask(mask)
              copy_image.matte = true
              copy_image = copy_image.composite(mask, Magick::CenterGravity, Magick::OverCompositeOp)
              copy_image.background_color = "none"
              copy_image.opacity = Magick::MaxRGB

            end

            save_image(copy_image,"wrap_Side_#{current_section.attributes['name']}.png")

            # Save the final wrap
            @wrap_final = @wrap_final.composite(copy_image, section_item.elements['x'].text.to_f, section_item.elements['y'].text.to_f, Magick::OverCompositeOp)
          end
        end
      end
    end

    # Refinal version to see the wrap without the overlay
    prefinal = @wrap_final.crop(
            @wrap_crop.elements['x'].text.to_f,
            @wrap_crop.elements['y'].text.to_f,
            @wrap_crop.elements['width'].text.to_f,
            @wrap_crop.elements['height'].text.to_f)

    save_image(prefinal,"wrap_final_before_Overlay.jpg")


    # Set all the overlays
    @wrap_overlays.elements.each do |overlay_element|
      # Only add images
      if overlay_element.attributes['type'] == "image"
        image_path = "#{@preview_asset_path}#{overlay_element.elements['fileName'].text}"
        overlay_image =  Image.read("#{image_path}").first
        overlay_image = overlay_image.resize(overlay_element.elements['width'].text.to_i, overlay_element.elements['height'].text.to_i)

        @wrap_final = @wrap_final.composite(overlay_image, overlay_element.elements['x'].text.to_f, overlay_element.elements['y'].text.to_f, Magick::OverCompositeOp)
      end
    end

    # Crop the wrap
    @wrap_final = @wrap_final.crop(
            @wrap_crop.elements['x'].text.to_f,
            @wrap_crop.elements['y'].text.to_f,
            @wrap_crop.elements['width'].text.to_f,
            @wrap_crop.elements['height'].text.to_f)

    save_image(@wrap_final,"wrap_final.jpg")
  end



  # ======================================
  # Save image
  # ======================================
  def self.save_image(image, name)
    #logger.debug "Saing #{@wrap_export_path}#{name}"

    image.write("#{@wrap_export_path}#{name}")

    @send_image_array.push(name)

  end


  # ======================================
  # Tests
  # ======================================

  def self.mask_test

    canvas = Magick::Image.new(1024,768)
    canvas.opacity = Magick::MaxRGB
    image = Magick::ImageList.new("#{@dropbox_path}maskImageb.png").first
    image.background_color = "none"
    #image.opacity = Magick::MaxRGB/2
    canvas.composite!(image, 50, 50, Magick::OverCompositeOp)
    save_image(canvas,'composite.png' )

=begin
    mask =  Image.read("#{@layout_asset_path}GalaxySIVBackOverlayMask.png").first
    background =  Image.read("#{@dropbox_path}art.jpg").first
    mask = mask.resize background.columns, background.rows

    grad = Image.read("#{@dropbox_path}baseImage.jpg").first

    background.add_compose_mask(mask)
    a = background.composite(mask, Magick::CenterGravity, Magick::OverCompositeOp)
    result = a.composite(grad, Magick::CenterGravity, Magick::OverCompositeOp)
    save_image(result, "test_mask.jpg")

=end
  end
end