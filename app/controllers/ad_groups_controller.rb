#!/bin/env ruby
# encoding: utf-8

class AdGroupsController < ApplicationController
  require 'adwords_api'
  PAGE_SIZE = 50
  before_action :set_ad_group, only: [:show, :edit, :update, :destroy]

  # GET /ad_groups
  # GET /ad_groups.json
  def index
    #@ad_groups = AdGroup.all
    @ad_groups = get_ad_groups(session[:active_camp])
  end

  # GET /ad_groups/1
  # GET /ad_groups/1.json
  def show
  end

  # GET /ad_groups/new
  def new
    @ad_group = AdGroup.new
  end

  # GET /ad_groups/1/edit
  def edit
  end

  # POST /ad_groups
  # POST /ad_groups.json
  def create
    @ad_group = AdGroup.new(ad_group_params)

    respond_to do |format|
      if @ad_group.save
        format.html { redirect_to @ad_group, notice: 'Ad group was successfully created.' }
        format.json { render :show, status: :created, location: @ad_group }
      else
        format.html { render :new }
        format.json { render json: @ad_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ad_groups/1
  # PATCH/PUT /ad_groups/1.json
  def update
    respond_to do |format|
      if @ad_group.update(ad_group_params)
        format.html { redirect_to @ad_group, notice: 'Ad group was successfully updated.' }
        format.json { render :show, status: :ok, location: @ad_group }
      else
        format.html { render :edit }
        format.json { render json: @ad_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_groups/1
  # DELETE /ad_groups/1.json
  def destroy
    @ad_group.destroy
    respond_to do |format|
      format.html { redirect_to ad_groups_url, notice: 'Ad group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def assign
    session[:active_gr] = params[:id]
    puts "<<<<<<<<<<<<<<<<<<<grupo activo<<<<<<<<<<<<<<<<<<<"
    puts session[:active_gr]
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    redirect_to root_path 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ad_group
      @ad_group = AdGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ad_group_params
      params.require(:ad_group).permit(:campaing_id, :name, :amount, :gr_id)
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

    def get_ad_groups(campaign_id)
      # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
      # when called without parameters.
      adwords = get_adwords_api()

      # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
      # the configuration file or provide your own logger:
      # adwords.logger = Logger.new('adwords_xml.log')

      ad_group_srv = adwords.service(:AdGroupService, get_api_version())

      # Get all the ad groups for this campaign.
      selector = {
        :fields => ['Id', 'Name'],
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => [
          {:field => 'CampaignId', :operator => 'IN', :values => [campaign_id]}
        ],
        :paging => {
          :start_index => 0,
          :number_results => PAGE_SIZE
        }
      }

      # Set initial values.
      offset, page = 0, {}

      begin
        page = ad_group_srv.get(selector)
        if page[:entries]
          page[:entries].each do |ad_group|
            puts "Ad group name is '%s' and ID is %d" %
                [ad_group[:name], ad_group[:id]]
          end
          # Increment values to request the next page.
          offset += PAGE_SIZE
          selector[:paging][:start_index] = offset
          return page[:entries]
        end
      end while page[:total_num_entries] > offset

      if page.include?(:total_num_entries)
        puts "\tCampaign ID %d has %d ad group(s)." %
            [campaign_id, page[:total_num_entries]]
      end
    end
end
