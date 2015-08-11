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




## Contributing

1. Fork it ( https://github.com/[my-github-username]/email_queue/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request