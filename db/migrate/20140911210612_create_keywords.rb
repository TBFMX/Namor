class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.integer :ad_group_id
      t.text :keywords

      t.timestamps
    end
  end
end
