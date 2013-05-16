class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_vars

  def set_vars
    # Desktop
    @dropbox_path =         "/Users/NestorCorrea/Dropbox/"
    @spree_gelaskins_path = "/Users/NestorCorrea/Projects/GelaSkins/Repositories/Git/GelaSkins/spree_gelaskins/"
    @wrap_export_path =     "/Users/NestorCorrea/Projects/GelaSkins/Repositories/Git/Nestor/Ruby-Imagemagic-Test/app/assets/images/image_exports/"

=begin
    # Laptop
    @dropbox_path = "/Users/Nestor/Dropbox/"
    @spree_gelaskins_path = "/Users/Nestor/Projects/Repositories/GelaSkins/spree_gelaskins/GelaSkins/spree_gelaskins/"
    @wrap_export_path = "/Users/Nestor/Projects/Repositories/Nestor/Ruby-Imagemagic-Test/app/assets/images/"

=end
  end
end
