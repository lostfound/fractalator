class IfsChainsController < FractalsController
  def create
    super do |fractal|
      fractal.pipeline = JSON.parse params[:ifs_chain][:pipeline], symbolize_names: true
    end
  end
  def fork
    super do |fractal|
      fractal.pipeline = fractal.parent.pipeline
    end
  end
  def update
    super do |fractal|
      fractal.pipeline = JSON.parse params[:ifs_chain][:pipeline], symbolize_names: true
    end
  end
  private
    def user_fractals user=nil
      u=user||current_user
      raise CanCan::AccessDenied if u.nil?
      u.ifs_chains
    end

    def glass
      IfsChain
    end

    def fractal_params
      params.require(:ifs_chain).permit %i[name description transforms rec_number base_shape image parent_id]
    end
end
