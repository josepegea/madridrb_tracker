class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.timestamp :moment, index: true
      t.point     :position
      t.float     :altitude
      t.float     :accuracy
      t.float     :speed
      t.float     :bearing
    end
  end
end
