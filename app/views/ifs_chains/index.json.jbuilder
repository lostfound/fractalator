json.array!(@ifss) do |iterated_function_system|
  json.extract! iterated_function_system, :id, :user_id, :name, :description, :transforms
  json.url iterated_function_system_url(iterated_function_system, format: :json)
end
