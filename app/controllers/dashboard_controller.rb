class DashboardController < ApplicationController
  def show
    gon.gymVisits = GymVisit.pluck(:date)
    gon.stepsCheckins = format_steps_checkins
  end

  private

  def format_steps_checkins
    checkins = {}
    StepsCheckin.all.each do |checkin|
      checkins["#{checkin.date.to_datetime.to_i}"] = checkin.n_steps
    end

    checkins
  end
end
