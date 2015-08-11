# EmailQueue
Asynchronous email queue implementation.

## Installation

1. install ruby 2.1.5
2. install mysql 5.5
3. create database named 'email_queue', username: 'root', password: 'root', this config can be changed in config/db.rb, app itself will take care of creating the schema.
4. `$ git clone https://github.com/manishgkasera/email_queue.git `
5. `$ cd email_queue`
6. install app dependencies with command `$ bundle install`
7. create the sample data `$ bundle exec ruby lib/email_queue/seed.rb`, this might take a few minutes as it creates 1000 queue items one by one, you can check the file lib/email_queue/seed.rb for the details.

## Usage
Run the application using the below command

    $ bundle exec ruby ./lib/email_queue/scripts/run.rb
you can run as many instances of the application as you want as per the requirement,
make sure to change the app_id in ./lib/email_queue/scripts/run.rb file to be uniq across systems and in the system.

## Testing
To test that the application is not processing the queue items multiple times
we can change the Job#process method (lib/email_queue/models/job.rb) to put an entry in a seperate db table for 'queue item id' after the job is processed and check for uniqueness after the all the jobs are processed.

If testing on a single system we can make a entry in a common file for each job processed and later check for uniqueness in that file. Sample code to put the entry in a file is as below
```ruby
File.open('/tmp/jobs_processed.log', 'a') do |f|
    f.write("Processing: " + queue_item.id.to_s + "\n")
end
```