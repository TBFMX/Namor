json.array!(@sessions) do |session|
  json.extract! session, :id, :session_id, :data
  json.url session_url(session, format: :json)
end
