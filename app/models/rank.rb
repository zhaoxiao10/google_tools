class Rank < ActiveRecord::Base
  attr_accessible :keyword_id, :rankdate, :ranknum, :keyword
  validates_uniqueness_of :keyword_id, :scope => :rankdate
  belongs_to :keyword
end
