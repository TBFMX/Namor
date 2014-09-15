json.array!(@ad_groups) do |ad_group|
  json.extract! ad_group, :id, :campaing_id, :name, :amount, :gr_id
  json.url ad_group_url(ad_group, format: :json)
end
