class IteratedFunctionSystemsController < ApplicationController
  before_action :set_iterated_function_system, only: [:show, :edit, :update, :destroy, :like]
  before_action :create_ifs, only: [:create]
  load_and_authorize_resource except: :like

  # GET /iterated_function_systems
  # GET /iterated_function_systems.json
  def index
    page = params[:page]
    page||=1
    unless params[:id]
      @ifss = IteratedFunctionSystem.where.not(name: '').order("score desc").order("created_at DESC").page(page).per(12)
    else
      uid = params[:id].to_i
      if current_user.id != uid
        @ifss = User.find(uid).ifss.where.not(name: '').order("score desc").order("created_at DESC").page(page).per(12)
      else
        @ifss = User.find(uid).ifss.order("created_at DESC").page(page).per(12)
      end
    end
  end

  # GET /iterated_function_systems/1
  # GET /iterated_function_systems/1.json
  def show
  end

  def like
    if user_signed_in?
      @ifs.likes.create user: current_user, score: (params[:negative])?-1:1 
      respond_to do |format|
        format.json do
          ret ={id: @ifs.id, score: IteratedFunctionSystem.find(@ifs.id).score}
          render json: ret.as_json
        end
      end
    end
  end

  # GET /iterated_function_systems/new
  def new
    @ifs = current_user.ifss.new
    @ifs.transforms = IteratedFunctionSystem.find(params[:clone]).transforms if params[:clone]
  end

  # GET /iterated_function_systems/1/edit
  def edit
  end

  # POST /iterated_function_systems
  # POST /iterated_function_systems.json
  def create
    respond_to do |format|
      if @ifs.save
        format.html { redirect_to @ifs, notice: 'Iterated function system was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ifs }
      else
        format.html { render action: 'new' }
        format.json { render json: @ifs.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /iterated_function_systems/1
  # PATCH/PUT /iterated_function_systems/1.json
  def update
    respond_to do |format|
      if @ifs.update(iterated_function_system_params)
        format.html { redirect_to @ifs, notice: 'Iterated function system was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ifs.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /iterated_function_systems/1
  # DELETE /iterated_function_systems/1.json
  def destroy
    @ifs.destroy
    respond_to do |format|
      format.html { redirect_to iterated_function_systems_url }
      format.json { head :no_content }
    end
  end

  def howto
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_iterated_function_system
      @ifs = IteratedFunctionSystem.find(params[:id])
      @iterated_function_system = @ifs
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def iterated_function_system_params
      params.require(:iterated_function_system).permit %i[name description transforms rec_number base_shape image]
    end
    def create_ifs
      @ifs = current_user.ifss.new iterated_function_system_params
      @iterated_function_system = @ifs
    end
end
