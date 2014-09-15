#!/bin/env ruby
# encoding: utf-8
class KeywordsController < ApplicationController
  before_action :set_keyword, only: [:show, :edit, :update, :destroy]

  # GET /keywords
  # GET /keywords.json
  def index
    @keywords = Keyword.all
  end

  # GET /keywords/1
  # GET /keywords/1.json
  def show
  end

  # GET /keywords/new
  def new
    @keyword = Keyword.new
  end

  # GET /keywords/1/edit
  def edit
  end

  # POST /keywords
  # POST /keywords.json
  def create
    
    aux = params[:keyword][:keywords]
    params[:keyword][:ad_group_id] = session[:active_gr]
    kws = aux.split(',').map(&:strip)

    ad_group_criteria = add_keywords(params[:keyword][:ad_group_id], kws)


    @keyword = Keyword.new(keyword_params)

    respond_to do |format|
      if @keyword.save
        format.html { redirect_to @keyword, notice: 'Keyword was successfully created.' }
        format.json { render :show, status: :created, location: @keyword }
      else
        format.html { render :new }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
   
  end

  # PATCH/PUT /keywords/1
  # PATCH/PUT /keywords/1.json
  def update
    respond_to do |format|
      if @keyword.update(keyword_params)
        format.html { redirect_to @keyword, notice: 'Keyword was successfully updated.' }
        format.json { render :show, status: :ok, location: @keyword }
      else
        format.html { render :edit }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.json
  def destroy
    @keyword.destroy
    respond_to do |format|
      format.html { redirect_to keywords_url, notice: 'Keyword was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyword
      @keyword = Keyword.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keyword_params
      params.require(:keyword).permit(:ad_group_id, :keywords)
    end
    def add_keywords(ad_group_id,kws)
      adwords = get_adwords_api()
      ad_group_criterion_srv = adwords.service(:AdGroupCriterionService, get_api_version())
        keywords = []
        kws.each do |k|
          keywords.push({:xsi_type => 'BiddableAdGroupCriterion',
            :ad_group_id => ad_group_id.to_i,
            :criterion => {
              :xsi_type => 'Keyword',
              :text => k.to_s,
              :match_type => 'BROAD'},
              # Optional fields:
            :user_status => 'PAUSED'
            })          
        end 

      # Create 'ADD' operations.
      operations = keywords.map do |keyword|
        {:operator => 'ADD', :operand => keyword}
      end
        
      # Add keywords.
      response = ad_group_criterion_srv.mutate(operations)
      #puts "6666666666666666666666666666666666666666666666666"
      if response and response[:value]
        ad_group_criteria = response[:value]
        puts "Added %d keywords to ad group ID %d:" %
            [ad_group_criteria.length, ad_group_id]
        ad_group_criteria.each do |ad_group_criterion|
          puts "\tKeyword ID is %d and type is '%s'" %
              [ad_group_criterion[:criterion][:id],
               ad_group_criterion[:criterion][:type]]
              return ad_group_criteria
        end
      else
        raise StandardError, 'No keywords were added.'
      end
    end
end
