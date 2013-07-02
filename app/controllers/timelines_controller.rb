# encoding: UTF-8
# Filter WorkLogs in different ways, with pagination

class TimelinesController < ApplicationController

  def show
    params[:filter_date]    ||= 1
    params[:filter_project] ||= 0
    params[:filter_status]  ||= -1
    @logs = EventLog.event_logs_for_timeline(current_user, params)

    respond_to do |format|
      format.html
      format.json
    end
  end

end
