class StepsCheckinRefresher
  def refresh
    if StepsCheckin.count > 0
      modified_timestamp = most_recent_modified_timestamp
    else
      modified_timestamp = 0
    end

    checkins = get_checkins_since(modified_timestamp)
  end

  private

  # Convert Azumio timestamp to Ruby datetime object.
  # Azumio timestamp is Unix epoch in milliseconds.
  def az_time(timestamp)
    Time.at(timestamp/1000).to_datetime
  end

  # Download all checkins since a given datetime
  def get_checkins_since(modified)
    agent = Mechanize.new
    page = agent.get("http://www.azumio.com/login")
    login_form = page.forms.first
    login_form.email = ENV["ZENKAI_AZUMIO_USERNAME"]
    login_form.password = ENV["ZENKAI_AZUMIO_PASSWORD"]
    login_form.submit

    checkins = []

    while(true)
      file = agent.get("https://www.azumio.com/v2/checkins?type=steps&modifiedAfter=#{modified}")
      data = JSON.parse(file.body)
      persist_checkins(data["checkins"])
      if(!data["hasMore"])
        break
      else
        modified = most_recent_modified_timestamp
      end
    end

    checkins
  end

  def persist_checkins(checkins)
    checkins.each do |checkin|
      # only support steps checkins for now.
      # TODO: Support Argus sleep checkins
      if checkin["type"] == "steps"
        checkin_params = {
          date: az_time(checkin["start"]).to_date,
          n_steps: checkin["steps"],
          modified_timestamp: checkin["modified"]
        }
        existing_checkin = StepsCheckin.find_by(date: checkin_params[:date])
        if existing_checkin
          existing_checkin.update! checkin_params
        else
          StepsCheckin.create! checkin_params
        end
      end
    end
  end

  def most_recent_modified_timestamp
    StepsCheckin.order(modified_timestamp: :desc).pluck(:modified_timestamp).first
  end
end
