namespace :accrual_amount do
  task :accrual_amount_call => :environment do
    AccrualService.call if Time.now.monday?
  end

  task :test => :environment do
    Telegram.bot.send_message chat_id: '3002462', text: 'Scheduler works fine!'
  end
end
