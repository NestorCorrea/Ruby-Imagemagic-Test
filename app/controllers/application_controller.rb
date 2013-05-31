class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_vars

  def set_vars
=begin
    # Laptop
    @dropbox_path =         "/Users/Nestor/Dropbox/"
    @customizer_path =      "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/"
    @wrap_export_path =     "/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/image_exports/"

    #Desktop
    @dropbox_path =         "/Users/NestorCorrea/Dropbox/"
    @customizer_path =      "/Users/NestorCorrea/wwwroot/skinCreator/"
    @wrap_export_path =     "/Users/NestorCorrea/Projects/GelaSkins/Repositories/Git/Nestor/Ruby-Imagemagic-Test/app/assets/images/image_exports/"
=end

    # Laptop
    @dropbox_path =         "/Users/Nestor/Dropbox/"
    @customizer_path =      "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/public/skinCreator/"
    @wrap_export_path =     "/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/image_exports/"
  end
end
