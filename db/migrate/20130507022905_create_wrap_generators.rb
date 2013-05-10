class CreateWrapGenerators < ActiveRecord::Migration
  def change
    create_table :wrap_generators do |t|
      t.timestamps
    end
  end



end
