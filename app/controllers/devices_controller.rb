class DevicesController < ApplicationController
  # GET /devices
  # GET /devices.json
  #include WrapGeneratorHelper

  def index
    @devices = Device.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @devices }
    end
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    @device = Device.find(params[:id])
    @artworks = Artwork.all
    @wrap_array = []

    @artworks.each do |image|
      #@wrap_array = generate_wrap
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @device }
    end
  end

  def copyover_when_done


    dropbox_path = "/Users/Nestor/Dropbox/"
    spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/"

    image_a = Dir.glob("#{dropbox_path}wrap_generator/source_images/*.jpg")

    counter = -1

    image_a.each do |image|

      counter = counter +1

      # Create the wrap
      ipad_front =    Image.read("#{spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/#{@device.front_image}").first
      ipad_back =     Image.read("#{spree_gelaskins_path}public/skinCreator/assets/layoutManagerAssets/layoutAssets/#{@device.back_image}").first
      spacer_white =  Image.new(50, 5000, Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF"))
      source_image =  Image.read(image_a[counter]).first

      skin_front =  source_image.composite(ipad_front, 0, 0, Magick::OverCompositeOp)
      skin_back =   source_image.composite(ipad_back,  0, 0, Magick::OverCompositeOp)

      canvas = Image::new(ipad_front.columns + ipad_back.columns + spacer_white.columns, ipad_front.rows)
      canvas = canvas.composite(skin_front,     0,                                          0, Magick::OverCompositeOp)
      canvas = canvas.composite(spacer_white,   ipad_front.columns,                         0, Magick::OverCompositeOp)
      canvas = canvas.composite(skin_back,      ipad_front.columns + spacer_white.columns,  0, Magick::OverCompositeOp)


      canvas.write("/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/" + counter.to_s + ".jpg")

      @wrap_array.push(counter.to_s + ".jpg")
      #canvas.write("#{dropbox_path}wrap_generator/wrap_export/" + counter.to_s + ".jpg")
      #@wrap_array.push("#{dropbox_path}wrap_generator/wrap_export/" + counter.to_s + ".jpg")
    end

  end


  # GET /devices/new
  # GET /devices/new.json
  def new

    @device = Device.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @device }
    end
  end

  # GET /devices/1/edit
  def edit
    @device = Device.find(params[:id])
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(params[:device])

    respond_to do |format|
      if @device.save
        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render json: @device, status: :created, location: @device }
      else
        format.html { render action: "new" }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /devices/1
  # PUT /devices/1.json
  def update
    @device = Device.find(params[:id])

    respond_to do |format|
      if @device.update_attributes(params[:device])
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device = Device.find(params[:id])
    @device.destroy

    respond_to do |format|
      format.html { redirect_to devices_url }
      format.json { head :no_content }
    end
  end
end
