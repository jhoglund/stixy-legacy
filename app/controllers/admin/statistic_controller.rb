
class Admin::StatisticController < Admin::AdminApplicationController
  def index
    session[:statistics_date] = params[:year] ? "#{params[:year]}-#{params[:month]}-1" : (session[:statistics_date] || Time.now.strftime("%Y-%m-01"))
    @date = Date.parse(session[:statistics_date])
    @previouse_date = @date << 1
    @next_date = @date >> 1
    @list = Statistic.get @date
  end
end
