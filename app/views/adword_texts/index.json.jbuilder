json.array!(@adword_texts) do |adword_text|
  json.extract! adword_text, :id, :group_id, :name, :ad_desc1, :ad_desc2, :ad_url, :ad_display, :adw_id
  json.url adword_text_url(adword_text, format: :json)
end
