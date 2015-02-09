class GymVisitRefresher
  def refresh
    visit_datetimes = get_visit_datetimes
    visit_datetimes.each do |visit_datetime|
      GymVisit.find_or_create_by!(
        date: visit_datetime.to_date,
        datetime: visit_datetime
      )
    end
  end

  private

  def get_visit_datetimes
    visit_datetimes = []

    agent = Mechanize.new
    page = agent.get("https://clients.mindbodyonline.com/classic/home?studioid=2043")

    # ugly login request, weird ASP page doesn't have a standard form on it
    agent.post("https://clients.mindbodyonline.com/Login?studioID=2043&isLibAsync=true&isJson=true&libAsyncTimestamp=1423431563216",
      {
        requiredtxtUserName: ENV["ZENKAI_VIM_USERNAME"],
        requiredtxtPassword: ENV["ZENKAI_VIM_PASSWORD"],
        date: Time.now.strftime("%-m/%-d/%Y"),
        classid: 0,
        isAsync: false
      }
    )
    page = agent.get("https://clients.mindbodyonline.com/classic/home?studioid=2043").frames.first.click
    page = page.link_with(text: "Visit History").click
    table = page.at("table.myInfoTable")
    rows = table.css("tr")[1..-1] # exclude header
    rows.each do |row|
      date_str = row.css("td")[0].text
      time_str = row.css("td")[2].text

      date = Date.strptime(date_str, "%m/%d/%Y")
      datetime = DateTime.parse("#{date} #{time_str}")
      visit_datetimes << datetime
    end

    visit_datetimes
  end
end
