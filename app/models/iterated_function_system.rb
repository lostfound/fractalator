require 'fileutils'
require 'base64'
class IteratedFunctionSystem < Fractal
  after_initialize :default_values
  attr_accessor :repeats
  #after_save :save_image
  #after_create :save_image
  #scope :named, -> {where.not name: ''}
  #scope :fresh, -> {order "created_at desc"}
  #scope :likest, ->{order "score desc"}

  SHAPES=[:rect, :circle]
  def fix_origins
    trans=JSON.parse transforms
    trans.each do |t|
      t.symbolize_keys!
      unless t[:originX] == 'center'
        t[:originX] = 'center'
        t[:originY] = 'center'
        sX = t[:scaleX]||1
        sY = t[:scaleY]||1
        angle = t[:angle]||0
        angle *= Math::PI / 180
        dx = t[:width]*sX/2
        dy = t[:height]*sY/2

        t[:left] += dx*Math::cos(angle) + dy*Math::sin(-angle)
        t[:top] += dx*Math::sin(angle) + dy*Math::cos(-angle)
      end
    end
    self.transforms = trans.to_json
    save
  end
private
  def default_values
    self.transforms||=[ {width: 200, height: 200, left: 100, top: 100, originX: 'center', originY: 'center'},
       {width: 200, height: 200, left: 300, top: 300, originX: 'center', originY: 'center'},
       {width: 200, height: 200, left: 100, top: 300, originX: 'center', originY: 'center'}].to_json
  end
end
