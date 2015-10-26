json.extract! @fractal, :id, :user_id, :name, :description, :created_at, :updated_at, :image_url
json.transforms JSON.parse @fractal.transforms
