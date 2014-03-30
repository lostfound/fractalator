class IteratedFunctionSystem < ActiveRecord::Base
  belongs_to :user
  before_validation :strips
  validates_presence_of :name
  validates_presence_of :description
  before_save :to_image
  def matrixs
    return @transmatrixs if @transmatrixs
    @transmatrixs = []
    transformations.each do |t|
      @transmatrixs<<[ t[:scale_x]*Math.cos( t[:angle_x].to_angle ),
                      t[:scale_x]*Math.sin( t[:angle_x].to_angle ),
                      t[:scale_y]*Math.sin( t[:angle_y].to_angle )*-1,
                      t[:scale_y]*Math.cos( t[:angle_y].to_angle ),
                      t[:trans_x], t[:trans_y] ]
    end
    @transmatrixs
  end
  def transformations
    return @transformations if @transformations
    @transformations = unless transforms.nil?
      JSON(transforms).map {|h| h.symbolize_keys}
    else
      [ {num: 1, scale_x: 0.5, scale_y: 0.5, angle_x: 0, angle_y: 0, trans_x: 0.25, trans_y: 0},
        {num: 2, scale_x: 0.5, scale_y: 0.5, angle_x: 0, angle_y: 0, trans_x: 0,    trans_y: 0.5},
        {num: 3, scale_x: 0.5, scale_y: 0.5, angle_x: 0, angle_y: 0, trans_x: 0.5,  trans_y: 0.5}]

    end
  end
private
  def strips
    self.name.try(:strip!)
    self.description.try(:strip!)
  end
  def to_image
    slim_path = Rails.root.join("app/views/iterated_function_systems/_svg.html.slim").to_s
    svg = Slim::Template.new(slim_path, {:pretty=>true}).render \
            Object.new, quality: :min, ifs: self
    svg_path = Rails.root.join("tmp", "out#{id}.svg").to_s
    prev_rec_img   = Rails.root.join( "tmp", "out#{id}.png").to_s
    next_rec_img   = Rails.root.join( "tmp", "out_next#{id}.png").to_s
    File.open(svg_path, "w") do |f|
      f.write svg.to_s
    end
    `convert #{svg_path} #{next_rec_img}`
    1.upto 9 do
      `rm -f #{prev_rec_img}`
      `mv #{next_rec_img} #{prev_rec_img}`
      svg = Slim::Template.new(slim_path, {:pretty=>true}).render \
              Object.new, quality: :min, ifs: self, image: prev_rec_img
      File.open(svg_path, "w") do |f|
        f.write svg.to_s
      end
      `convert #{svg_path} #{next_rec_img}`
    end
    rastor_dir = FileUtils.mkdir_p( Rails.root.join("public", "rastor", "ifs", self.id.to_s))[0].to_s
    `convert -scale 300x300 #{next_rec_img} #{rastor_dir}/thumb.png`
    `mv #{next_rec_img} #{rastor_dir}/image.png`
    `rm #{svg_path}`
    self.image = ["rastor", "ifs", self.id.to_s, "image.png"].join("/")
    self.image_thumb = ["rastor", "ifs", self.id.to_s, "thumb.png"].join("/")
  end
end
