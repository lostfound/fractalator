class IfsChain < Fractal
  attr_accessor :pipeline
  has_many :parts, foreign_key: :chain_id, dependent: :destroy
  after_create :create_pipeline
  after_update :update_pipeline
  def pipeline
    unless @pipeline
      @pipeline = parts.includes(:fractal).all.map do |part| 
        { transforms: JSON.parse(part.fractal.transforms, symbolize_names: true),
          repeats: part.repeats,
          ordernum: part.ordernum,
          image_url: part.fractal.image_url,
          id:       part.fractal.id
        }
      end
    else
      @pipeline
    end
  end
private
  def update_pipeline
    if @pipeline
      parts.delete_all
      begin
        create_pipeline
      rescue Exception => e
        logger.error e
        raise e
      end
    end
  end
  def create_pipeline
    pipeline.each_with_index do |part, i|
      logger.debug part[:id]
      logger.debug IteratedFunctionSystem.find(part[:id])
      parts.create! fractal: IteratedFunctionSystem.find(part[:id]), repeats: part[:repeats], ordernum: i
    end
  end
end
