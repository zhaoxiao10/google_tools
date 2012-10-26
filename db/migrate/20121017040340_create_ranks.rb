class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks do |t|
      t.integer :keyword_id
      t.integer :ranknum
      t.date :rankdate

      t.timestamps
    end
  end
end
