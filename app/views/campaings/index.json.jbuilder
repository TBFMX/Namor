json.array!(@campaings) do |campaing|
  json.extract! campaing, :id, :camp_name, :bud_name, :camp_id, :bud_id, :bud_amount
  json.url campaing_url(campaing, format: :json)
end
