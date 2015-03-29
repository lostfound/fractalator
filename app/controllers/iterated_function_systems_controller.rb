class IteratedFunctionSystemsController < ApplicationController
  before_action :set_iterated_function_system, only: %i[next prev show edit update destroy like]
  before_action :create_ifs, only: [:create]
  load_and_authorize_resource except: :like
  PER_PAGE=16

  # GET /iterated_function_systems
  # GET /iterated_function_systems.json
  def index
    page = params[:page]
    page||=1
    uid = nil
    unless params[:id]
      case params[:sort]
      when 'fresh'
        session[:ifs_sort] = 'fresh'
      when 'cools'
        session[:ifs_sort] = 'cools'
      end
    else
      uid = params[:id].to_i
    end
    @owner = uid.nil? ? nil : User.find(uid)
    @ifss = IteratedFunctionSystem.list( user_id: uid, me: current_user, sort: session[:ifs_sort]||'cools').page(page).per(PER_PAGE) 

  end

  # GET /iterated_function_systems/1
  # GET /iterated_function_systems/1.json
  def show
    @iter_args = {uid: params[:uid], sort: params[:sort], id: @ifs.id}
  end

  def next
    next_fractal = @ifs.next user_id: params[:uid], me: current_user, sort: params[:sort]
    redirect_to [next_fractal||@ifs, {uid: params[:uid], sort: params[:sort]}]
  end
  def prev
    prev_fractal = @ifs.prev user_id: params[:uid], me: current_user, sort: params[:sort]
    redirect_to [prev_fractal||@ifs, {uid: params[:uid], sort: params[:sort]}]
  end

  def like
    if user_signed_in?
      if params[:negative]
        @ifs.dislike_by current_user
      else
        @ifs.like_by current_user
      end
      respond_to do |format|
        format.json do
          ret ={id: @ifs.id, score: @ifs.score}
          render json: ret.as_json
        end
      end
    end
  end

  # GET /iterated_function_systems/new
  def new
    @ifs = current_user.ifss.new
    if params[:clone]
      parent = IteratedFunctionSystem.find(params[:clone])
      @ifs.transforms = parent.transforms 
      @ifs.rec_number = parent.rec_number
      @ifs.parent_id  = parent.id
    end
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
      format.html { redirect_to :back }
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
      params.require(:iterated_function_system).permit %i[name description transforms rec_number base_shape image parent_id]
    end
    def create_ifs
      @ifs = current_user.ifss.new iterated_function_system_params
      @iterated_function_system = @ifs
    end
end
