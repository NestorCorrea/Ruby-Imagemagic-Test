class CreateArtworks < ActiveRecord::Migration
  def change
    create_table :artworks do |t|
      t.string :artwork_name
      t.string :artwork
      t.string :artwork_file_name

      t.timestamps
    end
  end
end
