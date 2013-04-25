require 'rufus/scheduler'

def safely_schedule
  unless ActiveRecord::Base.connected?
    ActiveRecord::Base.connection.verify!(0)
  end

  Rails.logger.tagged "SCHEDULER" do
    yield
  end
rescue => e
  status e.inspect
ensure
  ActiveRecord::Base.connection_pool.release_connection
end

scheduler = Rufus::Scheduler.start_new

# Every morning at 6:17am
scheduler.cron '17 6 * * *' do
  safely_schedule do
    Rails.logger.info "Expire hide_until tasks"
    TaskRecord.expire_hide_until
  end
end

# Schedule tasks every 10 minutes
scheduler.every '10m' do
  safely_schedule do
    User.schedule_tasks
  end
end

# Every morning at 6:43am
scheduler.cron '43 6 * * *' do
  safely_schedule do
    Rails.logger.info "Recalculating score values for all the tasks"
    TaskRecord.calculate_score
  end
end
