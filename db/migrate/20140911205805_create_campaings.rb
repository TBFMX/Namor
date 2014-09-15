class CreateCampaings < ActiveRecord::Migration
  def change
    create_table :campaings do |t|
      t.string :camp_name
      t.string :bud_name
      t.integer :camp_id
      t.integer :bud_id
      t.integer :bud_amount

      t.timestamps
    end
  end
end
