#!/bin/env ruby
# encoding: utf-8
class CampaingsController < ApplicationController
  require 'adwords_api'
  PAGE_SIZE = 50
  before_action :set_campaing, only: [:show, :edit, :update, :destroy]

  # GET /campaings
  # GET /campaings.json
  def index
    #@campaings = Campaing.all
    @selected_account = selected_account

    if @selected_account
      response = request_campaigns_list()
      if response
        @campaigns = Campaign.get_campaigns_list(response)
        @campaign_count = response[:total_num_entries]
      end
    end
  end

  # GET /campaings/1
  # GET /campaings/1.json
  def show
    puts "<<<<<<<<<<<<<IdDeCampaña<<<<<<<<<<<<<<<<<<<"
    puts session[:active_camp]
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  # GET /campaings/new
  def new
    @campaing = Campaing.new
  end

  # GET /campaings/1/edit
  def edit
  end

  # POST /campaings
  # POST /campaings.json
  def create
    params[:campaing][:bud_amount] = (params[:campaing][:bud_amount].to_i)*1000000
    @campaing = Campaing.new(campaing_params)
    b_amount = params[:campaing][:bud_amount]
    adwords = get_adwords_api()
    #puts "<<<<<<<<<<<<<Adword<<<<<<<<<<<<<<<<<<<"
    #puts adwords
    #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    token = adwords.authorize()
    #puts "<<<<<<<<<<<<<<Amount<<<<<<<<<<<<<<<<<<"
    #puts b_amount
    #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    #####generamos el budget##############
    budget_id = create_budget(adwords,token,params[:campaing][:bud_name].to_s,b_amount)
    params[:campaing][:bud_id] = budget_id
    #####generamos la campaña#############
    camp_id = create_camp(adwords,token,budget_id.to_i,params[:campaing][:camp_name].to_s)
    params[:campaing][:camp_id] = camp_id

    @campaing = Campaing.new(campaing_params)


    respond_to do |format|
      if @campaing.save
        format.html { redirect_to @campaing, notice: 'Campaing was successfully created.' }
        format.json { render :show, status: :created, location: @campaing }
      else
        format.html { render :new }
        format.json { render json: @campaing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaings/1
  # PATCH/PUT /campaings/1.json
  def update
    respond_to do |format|
      if @campaing.update(campaing_params)
        format.html { redirect_to @campaing, notice: 'Campaing was successfully updated.' }
        format.json { render :show, status: :ok, location: @campaing }
      else
        format.html { render :edit }
        format.json { render json: @campaing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaings/1
  # DELETE /campaings/1.json
  def destroy
    @campaing.destroy
    respond_to do |format|
      format.html { redirect_to campaings_url, notice: 'Campaing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def assign
    session[:active_camp] = params[:id]
    puts "<<<<<<<<<<<<<<<<<<<campaña activa<<<<<<<<<<<<<<<<<<<"
    puts session[:active_camp]
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    redirect_to root_path 
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaing
      @campaing = Campaing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaing_params
      params.require(:campaing).permit(:camp_name, :bud_name, :camp_id, :bud_id, :bud_amount)
    end

    def create_budget(adw,tok,b_name,b_amount)
      puts"-----------------------------------------------------"
      puts adw
      puts tok
      puts b_name
      puts"-----------------------------------------------------"

      adwords = adw
      token = tok
      budget_srv = adwords.service(:BudgetService, get_api_version())
      budget = {
        :name => b_name.to_s,
        :amount => {:micro_amount => b_amount.to_i},
        :delivery_method => 'STANDARD',
        :period => 'DAILY'
      }
      #puts "1111111111111111"
      budget_operation = {:operator => 'ADD', :operand => budget}
      #puts"-----------------------------------------------------"
      #puts budget_operation.inspect
      #puts"-----------------------------------------------------"
      # Execute the new budget operation and save the assigned budget ID.
      return_budget = budget_srv.mutate([budget_operation])
      #puts "22222222222222222222"
      #puts"-----------------------------------------------------"
      #puts return_budget.inspect
      #puts"-----------------------------------------------------"

      budget_id = return_budget[:value].first[:budget_id]
      return budget_id
    end  

    def create_camp(adw,tok,b_id , c_name)
      #api = get_adwords_api()
      #service = api.service(:CampaignService, get_api_version())
      #@aux_camp_view = service
      #budget_id = add_budget(service)
      #########
      require 'adwords_api'

      adwords = get_adwords_api()
      token = adwords.authorize()
      ################
      #// obtener servicio.
      campaign_srv = adwords.service(:CampaignService, get_api_version())
      ################
      budget_id = b_id   
      puts "------------------------------------------"
      puts budget_id
      puts "------------------------------------------"
        # Create campañas.
      campaign = 
        {
          :name => c_name.to_s,
          :status => 'PAUSED',
          :bidding_strategy_configuration => {
            :bidding_strategy_type => 'MANUAL_CPC'
          },
          # Budget (required) - note only the budget ID is required.
          :budget => {:budget_id => budget_id},
          :advertising_channel_type => 'SEARCH',
          # Optional fields:
          :start_date =>
              DateTime.parse((Date.today + 1).to_s).strftime('%Y%m%d'),
          :ad_serving_optimization_status => 'ROTATE',
          :network_setting => {
            :target_google_search => true,
            :target_search_network => true,
            :target_content_network => true
          },
          :settings => [
            {
              :xsi_type => 'GeoTargetTypeSetting',
              :positive_geo_target_type => 'DONT_CARE',
              :negative_geo_target_type => 'DONT_CARE'
            },
            {
              :xsi_type => 'KeywordMatchSetting',
              :opt_in => true
            }
          ],
          :frequency_cap => {
            :impressions => '5',
            :time_unit => 'DAY',
            :level => 'ADGROUP'
          }
        }
      ###########################
      #generar el valor de operacion
      operations = [{:operator => 'ADD', :operand => campaign}]
      #############################
      #hacer el mutate del servicio a la operacion.
      response = campaign_srv.mutate(operations)
      ############################
      #evaluar respuesta
      if response and response[:value]
        puts "bien"
        response[:value].each do |campaign|
          puts "Campaign with name '%s' and ID %d was added." %
              [campaign[:name], campaign[:id]]
              session[:active_camp] = campaign[:id]
              return campaign[:id]
        end
      else
        raise new StandardError, 'No campaigns were added.'
        puts "mal"
      end
      ##############################
      session[:active_camp] = campaign[:id]
      return campaign[:id]
    end

    #obtiene las campañas actuales del client_id de adwords
    def request_campaigns_list()
      api = get_adwords_api()
      service = api.service(:CampaignService, get_api_version())
      selector = {
        :fields => ['Id', 'Name', 'Status'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :paging => {:start_index => 0, :number_results => PAGE_SIZE}
      }
      result = nil
      begin
        result = service.get(selector)
      rescue AdwordsApi::Errors::ApiException => e
        logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] =
            'API request failed with an error, see logs for details'

        rescue NoMethodError => e
        puts "----------------------------------------------------------------------------------------"
        puts 'hola'
        puts "----------------------------------------------------------------------------------------"
        
        logger.fatal("---------------------------EL PROBLEMA ES : %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] =
            'no se recibio respuesta del API de google, porfavor espere'
      end
      return result
    end
end
