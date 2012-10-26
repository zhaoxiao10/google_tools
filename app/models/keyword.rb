class Keyword < ActiveRecord::Base
  attr_accessible :language, :link, :name, :pagenum
  has_many :rank
  belongs_to :website
  
  before_save :default_values
  def default_values
    self.pagenum ||= 10
  end
    
end
