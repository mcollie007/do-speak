json.array!(@tasks) do |task|
  json.extract! task, :id, :item, :note, :done, :time
  json.url task_url(task, format: :json)
end
