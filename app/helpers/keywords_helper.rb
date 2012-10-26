require 'csv'

module KeywordsHelper
  def showcsv(keywords,ranks)
    CSV.generate do |csv|
      keywords.each do |keyword|
        ranks.each do |rank|
          ranknum = Rank.where(:keyword_id => keyword.id, :rankdate => rank.rankdate).first.ranknum unless Rank.where(:keyword_id => keyword.id, :rankdate => rank.rankdate).first.nil?
          csv << [ranknum]
        end
      end
    end
  end
end
