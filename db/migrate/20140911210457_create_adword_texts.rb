class CreateAdwordTexts < ActiveRecord::Migration
  def change
    create_table :adword_texts do |t|
      t.integer :group_id
      t.string :name
      t.string :name_gr
      t.string :amount
      t.string :ad_desc1
      t.string :ad_desc2
      t.text :ad_url
      t.string :ad_display
      t.integer :adw_id

      t.timestamps
    end
  end
end
