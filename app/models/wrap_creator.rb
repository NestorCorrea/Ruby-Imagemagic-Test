class WrapCreator < ActiveRecord::Base
  # attr_accessible :title, :body
  require 'json'


  # Store the device and artwork image
  @device
  @artwork

  @device_template

  @side_images

  @skin_generator
  @sections

  # ---- Skin Propeties ----
  @wrap_crop
  @wrap_overlays

  # Initial Variables
  @dropbox_path = "/Users/Nestor/Dropbox/"
  @spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"
  @layout_asset_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/layoutAssets/"
  @preview_asset_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/assets/layoutManagerAssets/previewAssets/"
  @wrap_export_path = "/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/"

  def self.create_wraps(current_device, current_image)

    # Store the device and artwork image
    @device = current_device
    @artwork = current_image

    @side_images = Hash.new

    # Load XML
    @source_image =  Image.read("#{@dropbox_path}wrap_generator/source_images/#{@artwork.artwork_file_name}").first

    # Load artwork file
    file = File.new( "#{@spree_gelaskins_path}public/skinCreator/config/devices/#{@device.dev_id}.xml")
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
        @wrap_overlays = skin_element.elements['overlayAssets']
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
      create_skin(current_section, 'skinart')

      @skin_canvas.write("#{@dropbox_path}skin.jpg" )
    end

    # Create the wraps
    sections.elements.each do |current_section|
      create_skin(current_section, 'skinwrap')
    end

    # Place the wrap overlays and cut them out
    sections.elements.each do |current_section|
      create_skin(current_section, 'place_overlay')
    end

    @wrap_overlays.elements.each do |overlay_element|
      # Only add images
      if overlay_element.attributes['type'] == "image"
        overlay_filename = overlay_element.elements['fileName'].text
        image_path = "#{@preview_asset_path}#{overlay_element.elements['fileName'].text}"
        logger.debug "opening #{image_path}"
        overlay_image =  Image.read("#{image_path}").first
        overlay_image = overlay_image.resize(overlay_element.elements['width'].text.to_i, overlay_element.elements['height'].text.to_i)

        @wrap_final = @wrap_final.composite(overlay_image,
                                            overlay_element.elements['x'].text.to_f,
                                            overlay_element.elements['y'].text.to_f,
                                            Magick::OverCompositeOp)
      end
    end

    @wrap_final = @wrap_final.crop(
        @wrap_crop.elements['x'].text.to_f,
        @wrap_crop.elements['y'].text.to_f,
        @wrap_crop.elements['width'].text.to_f,
        @wrap_crop.elements['height'].text.to_f
    )

    logger.debug "Has = #{@side_images}"

    @wrap_final.write("#{@wrap_export_path}#{@device.dev_id}-#{@artwork.artwork_file_name}")
    # The response back to the controller, this will return the path of the iamge
    "#{@device.dev_id}-#{@artwork.artwork_file_name}"
  end


# First step, generate the skin and wrap
  def self.create_skin(current_section, generatorType)
    # Skin Side
    if current_section.attributes['type'] == 'side'
      current_section.elements['sectionSkinConfig'].elements.each do |section_item|

        # Add to the skin art
        if section_item.attributes['name'] == 'skinart' && generatorType == 'skinart'
          @side_images[current_section.attributes['name']] = add_section_to_skin(section_item)


          logger.debug "Current Section  =  #{current_section.to_s}"

          # Add to the wrap
        elsif section_item.attributes['name'] == 'skinwrap' && generatorType == 'skinwrap'
          # Paste the section of the skin art onto the wrap canvas
          paste_to_wrap(section_item)

        elsif section_item.attributes['name'] == 'skinwrap' && generatorType == 'place_overlay'
          logger.debug "pasting Overlay = #{current_section.to_s}"

          # Cut out the overlay and then place it to the final wrap
          cropped = @wrap_canvas.crop(
              section_item.elements['x'].text.to_i,
              section_item.elements['y'].text.to_i,
              section_item.elements['width'].text.to_i,
              section_item.elements['height'].text.to_i)

          # Add an overlay mask if needed
          if current_section.elements['elements'].elements['overlayMask']
            logger.debug '===== OVERLAY MASK - FOUND FOR WRAP'
            overlay_mask =  Image.read("#{@layout_asset_path}#{current_section.elements['elements'].elements['overlayMask'].text}").first

            mask_canvas = Image::new(
                    section_item.elements['width'].text.to_i,
                    section_item.elements['height'].text.to_i){ self.background_color = "black" }

            mask_canvas = mask_canvas.composite(overlay_mask, 0, 0,Magick::OverCompositeOp)

            cropped = cropped.composite!(mask_canvas, CenterGravity, CopyOpacityCompositeOp)
            cropped.write("#{@dropbox_path}#{current_section.attributes['name']}.jpg" )

          else

            logger.debug '===== OVERLAY MASK - NOT    FOUND FOR WRAP'
          end

          @wrap_final = @wrap_final.composite(
              cropped,
              section_item.elements['x'].text.to_i,
              section_item.elements['y'].text.to_i,
              Magick::OverCompositeOp)
        end
      end
    end
  end


  def self.paste_to_wrap (section_item)
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

      copy_image = copy_image.resize(paste_w, paste_h)
      @wrap_canvas = @wrap_canvas.composite(copy_image,paste_x ,paste_y ,Magick::OverCompositeOp)
    end
  end


  def self.add_section_to_skin(section_item)
    logger.debug("+++++++++++ source_image W = #{@source_image.columns.to_s} x source_image H = #{@source_image.rows.to_s}")

    # Set the area parameters
    side_x =       section_item.elements['x'].text.to_f
    side_y =       section_item.elements['y'].text.to_f
    side_height =  section_item.elements['height'].text.to_i
    side_width =   section_item.elements['width'].text.to_i
    logger.debug("+++++++++++ side_height = #{side_height.to_s} x side_width = #{side_width.to_s}")


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

    # Place the sized art onto the canvas
    @skin_canvas =  @skin_canvas.composite(
        place_art,
        side_x,
        side_y  ,
        Magick::OverCompositeOp)

    place_art
  end



=begin
  def self.create_wraps(current_device, current_image)

    # Store the device and artwork image
    @device = current_device
    @artwork = current_image

    logger.debug "==============================================="
    logger.debug "Begining device id #{@device.dev_id}"

    # Load the device Templagte
    file = File.new( "#{@spree_gelaskins_path}public/skinCreator/config/devices/#{@device.dev_id}.xml").read
    @device_template = Hash.from_xml(file.to_s).to_json
    @device_template = JSON.parse(@device_template)
    @device_template = @device_template.to_hash

    #@device_hash = JSON.parse(@device_template)
    #@device_template = JSON.parse(@device_template)
    #@sections = @device_template.sections

    @sections = @device_template['device']['sections']['side']
    @skin_generator = @device_template['device']

    logger.debug "Begining sections = #{JSON.pretty_unparse @skin_generator}"

    #logger.debug "Begining sections = #{@sections}"
    #logger.debug "Begining sections = #{JSON.pretty_unparse @sections['side']}"
  end
=end
end
