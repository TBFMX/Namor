class AccountsController < ApplicationController
  require 'adwords_api'
  #before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  # GET /accounts.json
  def index
    #@accounts = Account.all
    @selected_account = selected_account
    graph = get_accounts_graph()
    @accounts = Account.get_accounts_map(graph)
  end

  def select()
    self.selected_account = params[:account_id]
    flash[:notice] = "Selected account: %s" % selected_account
    redirect_to root_path
  end
  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:name)
    end
    def get_accounts_graph()
      adwords = get_adwords_api()
      service = adwords.service(:ManagedCustomerService, get_api_version())
      selector = {:fields => ['Login', 'CustomerId', 'CompanyName']}
      result = nil
      begin
        result = adwords.use_mcc {service.get(selector)}
      rescue AdwordsApi::Errors::ApiException => e
        logger.fatal("---------------------------EL PROBLEMA ES : %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] =
            'Porfavor valide su informacion de factuaracion ante Google'
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
