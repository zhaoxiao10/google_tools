require 'open-uri'
require "faster_csv"

class KeywordsController < ApplicationController
  # GET /keywords
  # GET /keywords.json
  def index
    @order_by = params[:order]
    @website = Website.find(params[:website_id])
    @keywords = Keyword.order('').paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @keywords }
    end
  end

  # GET /keywords/1
  # GET /keywords/1.json
  def show
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/new
  # GET /keywords/new.json
  def new
    @keyword = Keyword.new
    @website = Website.find(params[:website_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @keyword }
    end
  end

  # GET /keywords/1/edit
  def edit
    @keyword = Keyword.find(params[:id])
  end

  # POST /keywords
  # POST /keywords.json
  def create
    #@keyword = Keyword.new(params[:keyword])
    @website = Website.find params[:website_id]
    @keyword = @website.keyword.build(params[:keyword])
    @keyword.link = @website.name
    
    respond_to do |format|
      if @keyword.save
        format.html { redirect_to website_keywords_path(@website), notice: 'Keyword was successfully created.' }
        format.json { render json: @keyword, status: :created, location: @keyword }
      else
        format.html { render action: "new" }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /keywords/1
  # PUT /keywords/1.json
  def update
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      if @keyword.update_attributes(params[:keyword])
        format.html { redirect_to @keyword, notice: 'Keyword was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.json
  def destroy
    @keyword = Keyword.find(params[:id])
    @website_id = @keyword.website_id
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to website_keywords_path(@website_id) }
      format.json { head :no_content }
    end
  end

  #爬取单个关键词
  def crawler
    @keyword = Keyword.find(params[:id])
    @website_id = @keyword.website_id
    crawler_single(@keyword,0)

    respond_to do |format|
      format.html { redirect_to website_keywords_path(@website_id) }
      format.json { head :no_content }
    end
  end
  
  #批量进行爬取
  def batchcrawler
    @keywords = Keyword.find_all_by_website_id(params[:website_id])
    @keywords.each_with_index do |k,index|
      crawler_single(k,index%3)
    end
    respond_to do |format|
      format.html { redirect_to website_keywords_path(params[:website_id]) }
      format.json { head :no_content }
    end
  end
  
  #展示图表
  def flotr
    @keyword = Keyword.find(params[:id])
    
    respond_to do |format|
      format.html { render :layout => false }# flotr.html.erb
      format.json { render :layout => false, json: @keyword }
    end
  end
  
  #批量new
  def batchnew
  end
  
  #批量add
  def batchadd
    @website = Website.find params[:website_id]
    #通过换行符来对关键词分组
    @keywordArray = params[:keywords].split(/[\r\n]+/)
    @keywordArray.map do |k|
       @keyword = @website.keyword.build(:name => k, :link => @website.name, :language => 'en')
       @keyword.save!
    end
    
    respond_to do |format|
        format.html { redirect_to website_keywords_path(@website) }
        format.json { head :no_content }
    end
  end
  
  def export
    @website = Website.find params[:website_id]
  end
  
  def doexport
    date = params[:date]
    @website = Website.find params[:website_id]
    @keywords = Keyword.find_all_by_link(@website.name)
    @ranks = Rank.find_by_sql(["select distinct rankdate from ranks where rankdate >= ? order by rankdate", date[:year]+"-"+date[:month]+"-"+date[:day]])
    respond_to do |format|         
      format.csv { render :layout => false }
      format.xls
    end
  end
  
  private
  #爬取单个关键词
  def crawler_single(kid,i)
    @keyword = kid
    useragent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:12.0) Gecko/20100101 Firefox/12.0'
    start = 0
    do_break = false
    #模拟用户cookie
    cookies = ['NID=64=A-D_X3_6jh5YJ889qwpYycnarrZ5A6mhVgjLbmk0YPt4-yZGc3YylbTX5xH4PLDn_XWwAvvAMEv0MhRF68BVwGNOVfYbdhUPn192jVE4Dw0v0kj_qFjC_8Gt5n0KJNiGZxke8qVeBYb4tyl_nT4;' + 
             ' PREF=ID=83689f22b817808b:U=448631db5ff57441:FF=0:LD=en:NR=100:NW=1:CR=2:TM=1350392085:LM=1350393251:SG=2:S=KUGsZ6WkaL7PFs-2',#cookie[0]
             
               'NID=65=uURSRXowCv6ElQkhuyIL0iuodZrvE5wFoZL9RqyQScNx1vQCtFn8G3H5ZoP2c4BssOSZtrX4ilBTq3eXvxMpFXU1uVgQcPTOea4cPxT3XAtFOZjlTqsaj6RXIP1_kg1MVAeEkvwy-dgO8rjcrBcOwZwiAm2t8U1A92znrFp-aE8CwYrZ6O1pe3gcZnDS;' +
             ' PREF=ID=4fac558c337353f3:U=d5646dec3386095e:FF=0:LD=en:NR=100:NW=1:CR=2:TM=1351231551:LM=1351232495:SG=2:S=9pluhl_NW9UFMvZn',#cookie[1]
             
               'NID=65=ngUXlzAHoW9j0My_R5OnfXKc3AfOMQADwHgRma5Vdcbff7AHbt5Iu4vkK8e0l4f1SLwz06QhsndwlUgWT4IuC4Y8YE73WGRnsfTras3WKCTEoXgDm0QQ184qAl1w67kx;' +
             ' PREF=ID=3be38e0624e27355:U=fdb8ad5fb9d63726:FF=0:NW=1:CR=2:TM=1351236032:LM=1351236042:S=1sGtJAbZv_rqx4V8']#cookie[2]
    begin
      while(start < 200) do
        url = "https://www.google.com/search?q=#{@keyword.name}&hl=#{@keyword.language}&prmd=imvns&ei=JPnJTvLFI8HlggeXwbRl&start=#{start}&sa=N&num=100"
        url = url.gsub(/[[:blank:]]/,'%20')
        p 'page is ' + url
        #doc = Nokogiri::HTML(open(url,'User-Agent' => useragent, 'Cookie' => cookies[i]))
        doc = Nokogiri::HTML(open(url, 'Cookie' => cookies[i]))
        doc.xpath('//*[@id="rso"]/li/div/h3/a').each_with_index do |d,index|
          unless d['href'].index(@keyword.link).nil?
            p 'this site is at ' + (index+1+start).to_s
            Rank.create(:ranknum => index+1+start, :rankdate => Time.now.to_date, :keyword => @keyword)
            do_break = true
            break
          end
        end
        break if do_break
        start += 100
      end
    rescue RuntimeError => ex
      puts ex
      puts 'cookie is no.' + i.to_s
    end
  end

end
