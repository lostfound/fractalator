class FractalsController < ApplicationController
  before_action :set_fractal, only: %i[fork next prev show edit update destroy like]
  before_action :create_fractal, only: [:create]
  load_and_authorize_resource except: :like
  PER_PAGE=24

  # GET /iterated_function_systems
  # GET /iterated_function_systems.json
  def index
    page = params[:page]
    page||=1
    uid = nil
    unless params[:id]
      case params[:sort]
      when 'fresh'
        session[:sort] = 'fresh'
      when 'cools'
        session[:sort] = 'cools'
      end
    else
      uid = params[:id].to_i
    end
    @owner = uid.nil? ? nil : User.find(uid)
    @fractals = glass.includes(:user).list( user_id: uid, me: current_user, sort: session[:sort]||'cools').page(page).per(PER_PAGE) 
    @can_i_like = Fractal.can_user_like current_user, @fractals.map {|f| f.id}
  end

  # GET /iterated_function_systems/1
  # GET /iterated_function_systems/1.json
  def show
    @iter_args = {uid: params[:uid], sort: params[:sort]}
    @ancestors = @fractal.parents.where.not(name: '')
    @children  = @fractal.all_children
    @can_i_like = Fractal.can_user_like current_user, @ancestors.ids+@children.map {|fr| fr.id}
    case @fractal
    when IfsChain
      @dna = @fractal.parts.includes(:fractal).map {|part| part.fractal.repeats= part.repeats;part.fractal}
      @can_i_like.merge Fractal.can_user_like current_user, @dna.map {|fr| fr.id}
      @hrd = 0
      @angular_controller = 'ifs_chain_animation'
      @angular_init       = {pipeline: @fractal.pipeline,
                             depth: @fractal.rec_number,
                             base_shape: @fractal.base_shape}.to_json
    when IteratedFunctionSystem
      @hrd = 5
      @angular_controller = 'ifs_animation'
      @angular_init       = {transforms: JSON.parse( @fractal.transforms ),
                             depth: @fractal.rec_number,
                             base_shape: @fractal.base_shape}.to_json
    end
  end

  def next
    next_fractal = @fractal.next user_id: params[:uid], me: current_user, sort: params[:sort]
    #redirect_to fractal_path(next_fractal||@fractal, {uid: params[:uid], sort: params[:sort]})
    redirect_to [next_fractal||@fractal, {uid: params[:uid], sort: params[:sort]}]
  end

  def prev
    prev_fractal = @fractal.prev user_id: params[:uid], me: current_user, sort: params[:sort]
    #redirect_to fractal_path(prev_fractal||@fractal, {uid: params[:uid], sort: params[:sort]})
    redirect_to [prev_fractal||@fractal, {uid: params[:uid], sort: params[:sort]}]
  end

  def like
    if user_signed_in?
      if params[:negative]
        @fractal.dislike_by current_user
      else
        @fractal.like_by current_user
      end
      respond_to do |format|
        format.json do
          ret ={id: @fractal.id, score: @fractal.score}
          render json: ret.as_json
        end
      end
    end
  end

  def fork
    @fractal = glass.new transforms: @fractal.transforms, rec_number: @fractal.rec_number, parent: @fractal, base_shape: @fractal.base_shape
    yield @fractal if block_given?
    render 'new'
  end
  # GET /iterated_function_systems/new
  def new
    @fractal = user_fractals.new
    #if params[:clone]
    #  parent = glass.find(params[:clone].to_i)
    #  raise CanCan::AccessDenied if parent.user != current_user and parent.name.to_s == ''
    #  @fractal.transforms = parent.transforms 
    #  @fractal.rec_number = parent.rec_number
    #  @fractal.parent_id  = parent.id
    #end
  end

  # GET /iterated_function_systems/1/edit
  def edit
  end

  # POST /iterated_function_systems
  # POST /iterated_function_systems.json
  def create
    yield @fractal if block_given?
    respond_to do |format|
      if @fractal.save
        format.html { redirect_to @fractal, notice: 'Fractal was successfully created.' }
        format.json { render action: 'show', status: :created, location: @fractal }
      else
        format.html { render action: 'new' }
        format.json { render json: @fractal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /iterated_function_systems/1
  # PATCH/PUT /iterated_function_systems/1.json
  def update
    yield @fractal if block_given?
    respond_to do |format|
      if @fractal.update(fractal_params)
        format.html { redirect_to @fractal, notice: 'Fractal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fractal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /iterated_function_systems/1
  # DELETE /iterated_function_systems/1.json
  def destroy
    @fractal.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  def howto
  end

  private
    def glass
      Fractal
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_fractal
      @fractal = glass.find(params[:id])
      # cancan requires this class variable before action
      instance_variable_set "@#{glass.to_s.underscore.singularize}", @fractal
    end
    def create_fractal
      @fractal = user_fractals.new fractal_params
      # cancan requires this class variable before action
      instance_variable_set "@#{glass.to_s.underscore.singularize}", @fractal
    end

end

