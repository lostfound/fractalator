require 'fileutils'
require 'base64'
class IteratedFunctionSystem < Fractal
  after_initialize :default_values
  #after_save :save_image
  #after_create :save_image
  #scope :named, -> {where.not name: ''}
  #scope :fresh, -> {order "created_at desc"}
  #scope :likest, ->{order "score desc"}

  SHAPES=[:rect, :circle]
  def save_image
    if image and image.start_with? 'data:image'
      FileUtils.mkdir_p(Rails.application.root.join 'public', 'fractals', 'ifs', "#{id}")
      binary = Base64.decode64(image.gsub(/^data:image\/(png|jpg);base64,/, ''))
      file_path = Rails.application.root.join('public', 'fractals', 'ifs', "#{id}", "#{Time.new.to_f.to_s}.png")
      File.open file_path, "wb" do |f|
        f.write binary
      end
      self.image = '/' + ['fractals', 'ifs', "#{id}", file_path.basename].join('/')
      save
    end
  end
private
  def default_values
    self.transforms||=[ {width: 200, height: 200, left: 0, top: 0},
       {width: 200, height: 200, left: 200, top: 200},
       {width: 200, height: 200, left: 0, top: 200}].to_json
  end
end
