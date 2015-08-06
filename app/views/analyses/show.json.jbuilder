json.set! :id, @analysis.id.to_s
json.set! :user_id, @analysis.user.id.to_s
json.set! :structures_count, @analysis.structures_count
json.extract! @analysis, :name, :display_name, :description, :user_defined_id, :user_created_date, :analysis_types, :analysis_information, :created_at, :updated_at

  
