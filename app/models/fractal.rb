class Fractal < ActiveRecord::Base

  belongs_to :user
  belongs_to :parent, class_name: 'Fractal', foreign_key: :parent_id
  has_many   :childrens, class_name: 'Fractal', foreign_key: :parent_id, dependent: :nullify
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


  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def self.tree_for(instance)
    where("#{table_name}.id IN (#{tree(instance)})").order("#{table_name}.id")
  end

  def self.tree(instance)
    tree_sql =  <<-SQL
      WITH RECURSIVE
        tree(n) AS (
          VALUES(#{instance.id})
          UNION
          SELECT id FROM fractals, tree
           WHERE fractals.parent_id = tree.n
        )
      SELECT id FROM fractals
       WHERE fractals.id IN tree
    SQL
  end

private
  def strips
    self.name.try(:strip!)
  end
end

