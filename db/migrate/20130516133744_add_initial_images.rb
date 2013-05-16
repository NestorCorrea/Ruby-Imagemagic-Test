class AddInitialImages < ActiveRecord::Migration
  def up
    Artwork.delete_all
    save_image = Artwork.new(artwork_name:'Bookshelf', artist_name:'Colin Thompson', artwork_file_name:'153.jpg')
    save_image.save

    save_image = Artwork.new(artwork_name:'Climb', artist_name:'Lawrence Yang', artwork_file_name:'788.jpg')
    save_image.save

    save_image = Artwork.new(artwork_name:'Mona Lisa', artist_name:'Leonardo Davinci', artwork_file_name:'1191.jpg')
    save_image.save

    save_image = Artwork.new(artwork_name:'Meow', artist_name:'Melani Mikez', artwork_file_name:'1040.jpg')
    save_image.save

    save_image = Artwork.new(artwork_name:'Growth', artist_name:'Lawrence Yang', artwork_file_name:'157.jpg')
    save_image.save

    save_image = Artwork.new(artwork_name:'Sea Garden', artist_name:'Julie Comstock', artwork_file_name:'812.jpg')
    save_image.save
``
    save_image = Artwork.new(artwork_name:'Meat City', artist_name:'Brian Barneclo', artwork_file_name:'1184.jpg')
    save_image.save
  end

  def down
  end
end
