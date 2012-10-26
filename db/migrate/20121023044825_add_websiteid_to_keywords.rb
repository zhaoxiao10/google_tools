class AddWebsiteidToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :website_id, :integer
  end
end
