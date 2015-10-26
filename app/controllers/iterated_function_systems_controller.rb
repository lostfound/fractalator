class IteratedFunctionSystemsController < FractalsController
  def index
    super
    if params[:layout]=='chain'
      render 'index_chain', layout: false
    end
  end
  private
    def user_fractals user=nil
      u=user||current_user
      raise CanCan::AccessDenied if u.nil?
      u.ifss
    end

    def glass
      IteratedFunctionSystem
    end

    def fractal_params
      params.require(:iterated_function_system).permit %i[name description transforms rec_number base_shape image parent_id]
    end
end
