class CreateAdGroups < ActiveRecord::Migration
  def change
    create_table :ad_groups do |t|
      t.integer :campaing_id
      t.string :name
      t.integer :amount
      t.integer :gr_id

      t.timestamps
    end
  end
end
