class CreateWrapCreators < ActiveRecord::Migration
  def change
    create_table :wrap_creators do |t|

      t.timestamps
    end
  end
end
