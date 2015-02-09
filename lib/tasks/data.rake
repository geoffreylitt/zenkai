namespace :data do
  desc "TODO"
  task refresh: :environment do
    DataRefresher.new.refresh_all
  end

end
