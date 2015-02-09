class DashboardController < ApplicationController
  def show
    gon.gymVisits = GymVisit.pluck(:date)
    gon.stepsCheckins = format_steps_checkins
  end

  private

  def format_steps_checkins
    checkins = {}
    StepsCheckin.all.each do |checkin|
      datetime = checkin.date.to_datetime + 5.hours #EST
      timestamp = datetime.to_i.to_s
      checkins[timestamp] = checkin.n_steps
    end

    checkins
  end
end
