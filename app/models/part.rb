class Part < ActiveRecord::Base
  belongs_to :fractal
  belongs_to :chain, class_name: :Fractal
  validates  :fractal, :chain, presence: true
  default_scope -> {order :ordernum}
end
