class Fractal < ActiveRecord::Base

  belongs_to :user
  belongs_to :parent, class_name: 'Fractal', foreign_key: :parent_id
  has_many   :children, class_name: 'Fractal', foreign_key: :parent_id#, dependent: :nullify
  before_destroy :change_children_parent
  #validates :name,  presence: true, allow_blank: false
  validates :rec_number, numericality: {greater_than: 0}
  validates :parent, presence: true, unless: 'parent_id.nil?'
  validate  :parent_cannot_be_me
  validate  :name_must_be_ascii_only
  before_validation :strips
  scope :named, -> {where.not name: ''}
  scope :fresh, -> {order "created_at desc"}

  include Likeable
  #mount_uploader :image, FractalUploader
  mount_base64_uploader :image, FractalUploader

  
  def self.typed
    if name != 'Fractal'
      where(type: name)
    else
      all
    end
  end
  def self.list args={}
    unless args[:user_id]
      case (args[:sort]||:cools).to_sym
      when :fresh
        Fractal.typed.named.fresh.includes(:user)
      else
        Fractal.typed.named.likest.fresh.includes(:user)
      end
    else
      if args[:me].nil? or args[:me].id != args[:user_id].to_i
        @owner = User.find args[:user_id]
        @owner.fractals.typed.named.fresh.includes(:user)
      else
        args[:me].fractals.typed.fresh.includes(:user)
      end
    end
  end
  def next args={}
    unless args[:user_id]
      case (args[:sort]||:cools).to_sym
      when :fresh
        self.class.list(args).where('created_at > ?', created_at).last
      else
        self.class.list(args).where('(created_at > ? and score = ?) or (score > ?)', created_at, score, score).last
      end
    else
      self.class.list(args).where('created_at > ?', created_at).last
    end
  end
  def prev args={}
    unless args[:user_id]
      case (args[:sort]||'cools').to_sym
      when :fresh
        self.class.list(args).where('created_at < ?', created_at).first
      else
        self.class.list(args).where('(created_at < ? and score = ?) or (score < ?)', created_at, score, score).first
      end
    else
      self.class.list(args).where('created_at < ?', created_at).first
    end
  end

  def all_children
    self.class.tree_for(self).where.not(name: '') - [self]
  end
  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def self.tree_for(instance, reversed=false)
    if reversed
      where("#{table_name}.id IN (#{tree_rev(instance)})").order("#{table_name}.id")
    else
      where("#{table_name}.id IN (#{tree(instance)})").order("#{table_name}.id")
    end
  end

  def parents
    self.class.tree_for(self, true)
  end

  def grandparent
    parents.where(parent_id: nil).first
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
  def self.tree_rev(instance)
    tree_sql =  <<-SQL
      WITH RECURSIVE
        tree(n) AS (
          VALUES(#{instance.parent_id||-1})
          UNION
          SELECT parent_id FROM fractals, tree
           WHERE fractals.id = tree.n
        )
      SELECT id FROM fractals
       WHERE fractals.id IN tree
    SQL
  end

private
  def name_must_be_ascii_only
    unless name.nil?
      errors.add(:name, 'must be english word or sentence') unless name.ascii_only?
    end
  end
  def parent_cannot_be_me
    if not id.nil? and id == parent_id
      errors.add(:parent, "Can't be parent himself")
    end
  end
  def change_children_parent
    children.update_all parent_id: parent_id
  end
  def strips
    self.name.try(:strip!)
  end
end

