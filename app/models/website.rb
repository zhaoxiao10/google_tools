class Website < ActiveRecord::Base
  attr_accessible :name
  has_many :keyword
end
