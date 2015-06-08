namespace :cleanup do
  desc 'clear metas collection'
  task clear_metas: :environment do
    Meta.delete_all
  end

  desc 'clear structures and all associated content'
  task clear_structures: :environment do
    Structure.delete_all
    MeasureInstance.delete_all
    Analysis.delete_all
    MeasureDescription.delete_all
  end

  desc 'migrate provenance to analysis'
  task migrate_to_analysis: :environment do
    # change provenances collection to 'analyses'
    Mongoid::Sessions.default[:provenances].rename(:analyses)

    # change all provenance_id in structures to 'analysis_id'
    Structure.exists(provenance_id: true).each do |bld|
      bld.rename(provenance_id: :analysis_id)
    end
  end
end
