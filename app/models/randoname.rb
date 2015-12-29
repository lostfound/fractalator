class Randoname < ActiveRecord::Base
  belongs_to :user
  before_create :gen_names
  def get_names
    if pos >= 150
      gen_names
      save
    end
    ret=JSON.parse(names)[pos, 10]
    update pos: pos+10
    ret
  end
  def is_name_valid? name
    JSON.parse(names).include? name
  end
private
  def gen_names
    self.names = 150.times.map {Faker::Name.name}.to_json
    self.pos = 0
  end
end
