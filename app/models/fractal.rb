class Fractal < ActiveRecord::Base

  belongs_to :user
  #validates :name,  presence: true, allow_blank: false
  before_validation :strips
  scope :named, -> {where.not name: ''}
  scope :fresh, -> {order "created_at desc"}
  scope :likest, ->{order "score desc"}

  has_many :likes, as: :likeable
  #mount_uploader :image, FractalUploader
  mount_base64_uploader :image, FractalUploader
  def fix_image
    i = image.to_s.index 'fractals'
    return if i.nil?
    path = 'public/' + image.to_s[i..-1]
    File.open path, 'rb' do |f|
      self.update image: f
    end
  end
private
  def strips
    self.name.try(:strip!)
  end
end

