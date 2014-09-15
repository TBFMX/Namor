#!/bin/env ruby
# encoding: utf-8
require 'adwords_api'
class AdwordTextsController < ApplicationController
  before_action :set_adword_text, only: [:show, :edit, :update, :destroy]

  # GET /adword_texts
  # GET /adword_texts.json
  def index
    #@adword_texts = AdwordText.all
    if session[:active_gr].blank?
      redirect_to root_path
    end 

    #traer todos los anuncios de un grupo
    begin
      # Ad group ID to get text ads for.
      ad_group_id = session[:active_gr].to_i
      @adword_texts = get_text_ads(ad_group_id)
    # Authorization error.
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
          "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
          "to retrieve and store OAuth2 tokens."
      puts "See this wiki page for more details:\n\n  " +
          'http://code.google.com/p/google-api-ads-ruby/wiki/OAuth2'

    # HTTP errors.
    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

    # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
    end
    
  end

  # GET /adword_texts/1
  # GET /adword_texts/1.json
  def show

  end

  # GET /adword_texts/new
  def new
    @adword_text = AdwordText.new
    if session[:active_camp].blank?
      redirect_to campaings_path, notice: "seleccione una campaña para poder proseguir"
    end 

  end

  # GET /adword_texts/1/edit
  def edit
  end

  # POST /adword_texts
  # POST /adword_texts.json
  def create
    campaign_id = session[:active_camp]
    ####################################################################

    params[:adword_text][:amount] = (params[:adword_text][:amount].to_i)*1000000
    api_v = get_api_version()
    gr_name = params[:adword_text][:name_gr]
    gr_amount = params[:adword_text][:amount]
    ad_group_id = add_ad_groups(campaign_id, api_v, gr_name, gr_amount)
    params[:adword_text][:group_id] = ad_group_id
    puts"------------------------"
    puts ad_group_id
    puts"------------------------"
   
    ###################################################################
    #ad_group_id = 15011254977
    ad_name = params[:adword_text][:name]
    ad_desc1 = params[:adword_text][:ad_desc1]
    ad_desc2 = params[:adword_text][:ad_desc2]
    ad_url = params[:adword_text][:ad_url]
    ad_display = params[:adword_text][:ad_display]
    add_text_id = add_text_ads( ad_group_id, ad_name, ad_desc1, ad_desc2, ad_url, ad_display)
    params[:adword_text][:adw_id] = add_text_id
    ##########################################################################################

    @ad_group = AdGroup.new(:name => params[:adword_text][:name_gr], :amount => params[:adword_text][:amount], :gr_id => ad_group_id, :campaing_id => campaign_id)
    respond_to do |format|
      if @ad_group.save
        format.html { 
          @adword_text = AdwordText.new(adword_text_params)
          respond_to do |format|
            if @adword_text.save
              format.html { redirect_to @adword_text, notice: 'Adword text was successfully created.' }
              format.json { render :show, status: :created, location: @adword_text }
            else
              format.html { render :new }
              format.json { render json: @adword_text.errors, status: :unprocessable_entity }
            end
          end
         }
        format.json { render :show, status: :created, location: @ad_group }
      else
        format.html { render :new }
        format.json { render json: @ad_group.errors, status: :unprocessable_entity }
      end
    end  
  end

  # PATCH/PUT /adword_texts/1
  # PATCH/PUT /adword_texts/1.json
  def update
    respond_to do |format|
      if @adword_text.update(adword_text_params)
        format.html { redirect_to @adword_text, notice: 'Adword text was successfully updated.' }
        format.json { render :show, status: :ok, location: @adword_text }
      else
        format.html { render :edit }
        format.json { render json: @adword_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adword_texts/1
  # DELETE /adword_texts/1.json
  def destroy
    @adword_text.destroy
    respond_to do |format|
      format.html { redirect_to adword_texts_url, notice: 'Adword text was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adword_text
      @adword_text = AdwordText.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adword_text_params
      params.require(:adword_text).permit(:group_id, :name, :ad_desc1, :ad_desc2, :ad_url, :ad_display, :adw_id)
    end

    def add_ad_groups(campaign_id, api_v, ad_name, gr_amount)
      adwords = get_adwords_api()
      ad_group_srv = adwords.service(:AdGroupService, api_v)
      ad_groups = [
        {
          :name => ad_name.to_s,
          :status => 'PAUSED',
          :campaign_id => campaign_id.to_i,
          :bidding_strategy_configuration => {
            :bids => [
              {
                :xsi_type => 'CpcBid',
                :bid => {:micro_amount => gr_amount.to_i}
              }
            ]
          },
          :settings => [
            {
              :xsi_type => 'TargetingSetting',
              :details => [
                {
                  :xsi_type => 'TargetingSettingDetail',
                  :criterion_type_group => 'PLACEMENT',
                  :target_all => true
                },
                {
                  :xsi_type => 'TargetingSettingDetail',
                  :criterion_type_group => 'VERTICAL',
                  :target_all => false
                }
              ]
            }
          ]
        }      
      ]
      operations = ad_groups.map do |ad_group|
        {:operator => 'ADD', :operand => ad_group}
      end
      # Add ad groups.
      aux = ""
      response = ad_group_srv.mutate(operations)
      if response and response[:value]
        response[:value].each do |ad_group|
          puts "Ad group ID %d was successfully added." % ad_group[:id]
          aux = ad_group[:id]
        end
      else
        raise StandardError, 'No ad group was added'
      end
      return aux
    end

    def add_text_ads(ad_group_id, ad_name,ad_desc1, ad_desc2, ad_url, ad_display )
      adwords = get_adwords_api()
      ad_group_ad_srv = adwords.service(:AdGroupAdService, get_api_version())
      text_ads = [
        {
          :xsi_type => 'TextAd',
          :headline => ad_name.to_s,
          :description1 => ad_desc1.to_s,
          :description2 => ad_desc2.to_s,
          :url => ad_url.to_s,
          :display_url => ad_display.to_s
        }
      ]

      puts "<<<<<<<<<<<<<<<<<<<text_ads<<<<<<<<<<<<<<<<<<<"
      puts text_ads.inspect
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      # Create ad 'ADD' operations.
      text_ad_operations = text_ads.map do |text_ad|
        {:operator => 'ADD',
         :operand => {:ad_group_id => ad_group_id.to_i, :ad => text_ad}}
      end

      # Add ads.
      aux =""
      response = ad_group_ad_srv.mutate(text_ad_operations)
      if response and response[:value]
        ads = response[:value]
        puts "Added %d ad(s) to ad group ID %d:" % [ads.length, ad_group_id]
        ads.each do |ad|
          puts "\tAd ID %d, type '%s' and status '%s'" %
              [ad[:ad][:id], ad[:ad][:ad_type], ad[:status]]
          aux = ad[:ad][:id]
          return aux
        end
      else
        raise StandardError, 'No ads were added.'
      end
    end

    def get_text_ads(ad_group_id)
      # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
      # when called without parameters.
      adwords = get_adwords_api()

      # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
      # the configuration file or provide your own logger:
      # adwords.logger = Logger.new('adwords_xml.log')

      ad_group_ad_srv = adwords.service(:AdGroupAdService, get_api_version())

      # Get all the ads for this ad group.
      selector = {
        :fields => ['Id', 'Status', 'AdType'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        # By default, disabled ads aren't returned by the selector. To return them,
        # include the DISABLED status in a predicate.
        :predicates => [
          {:field => 'AdGroupId', :operator => 'IN', :values => [ad_group_id]},
          {:field => 'Status',
           :operator => 'IN',
           :values => ['ENABLED', 'PAUSED', 'DISABLED']},
          {:field => 'AdType',
           :operator => 'EQUALS',
           :values => ['TEXT_AD']}
        ],
        :paging => {
          :start_index => 0,
          :number_results => PAGE_SIZE
        }
      }

      # Set initial values.
      offset, page = 0, {}

      begin
        page = ad_group_ad_srv.get(selector)
        if page[:entries]
          page[:entries].each do |ad|
            puts "Ad ID is %d, type is '%s' and status is '%s'" %
                [ad[:ad][:id], ad[:ad][:ad_type], ad[:status]]
          end
          # Increment values to request the next page.
          offset += PAGE_SIZE
          selector[:paging][:start_index] = offset
        end
      end while page[:total_num_entries] > offset

      if page.include?(:total_num_entries)
        puts "\tAd group ID %d has %d ad(s)." %
            [ad_group_id, page[:total_num_entries]]
      end
    end
end
