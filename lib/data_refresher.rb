class DataRefresher
  def refresh_all
    refresher_classes = [
      GymVisitRefresher,
      StepsCheckinRefresher
    ]

    # Each refresher class must expose a refresh method that handles
    # updating data and persisting it as necessary.
    refresher_classes.each do |refresher_class|
      refresher_class.new.refresh
    end
  end
end
