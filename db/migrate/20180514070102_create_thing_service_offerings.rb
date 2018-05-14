class CreateThingServiceOfferings < ActiveRecord::Migration
  def change
    create_table :thing_service_offerings do |t|
      t.references :service_offering, index: true, foreign_key: true
      t.references :thing, index: true, foreign_key: true
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end
