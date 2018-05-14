class CreateServiceOfferings < ActiveRecord::Migration
  def change
    create_table :service_offerings do |t|
      t.string :public_field
      t.string :non_public_field

      t.timestamps null: false
    end
  end
end
