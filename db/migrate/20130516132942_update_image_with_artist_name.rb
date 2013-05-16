class UpdateImageWithArtistName < ActiveRecord::Migration
  def up
    add_column :artworks, :artist_name, :string
  end

  def down
  end
end
