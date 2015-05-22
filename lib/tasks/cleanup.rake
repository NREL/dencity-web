namespace :cleanup do
  desc 'clear metas collection'
  task clear_metas: :environment do
    Meta.delete_all
  end

  desc 'clear structures and all associated content'
  task clear_structures: :environment do
    Structure.delete_all
    Attachment.delete_all
    MeasureInstance.delete_all
    Provenance.delete_all
    MeasureDescription.delete_all
  end
end
