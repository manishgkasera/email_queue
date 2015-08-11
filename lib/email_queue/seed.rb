require 'email_queue'
require 'faker'

1000.times do
  from = Faker::Internet.safe_email
  to = 'a@a.com'
  subject =  Faker::Hacker.say_something_smart
  body =  Faker::Lorem.paragraph(50)
  EmailQueue::Queue.enqueue(from, to, subject, body)
end