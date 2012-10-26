class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :name
      t.string :link
      t.integer :pagenum
      t.string :language

      t.timestamps
    end
  end
end
