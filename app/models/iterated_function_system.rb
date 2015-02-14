class IteratedFunctionSystem < ActiveRecord::Base
  belongs_to :user
  validates :name,  presence: true, allow_blank: false
  after_initialize :default_values
  #before_destroy :rm_images

  has_many :likes, as: :likeable
  SHAPES=[:rect, :circle]
private
  def strips
    self.name.try(:strip!)
  end
  def default_values
    self.transforms||=[ {width: 200, height: 200, left: 0, top: 0},
       {width: 200, height: 200, left: 200, top: 200},
       {width: 200, height: 200, left: 0, top: 200}].to_json
  end
end
