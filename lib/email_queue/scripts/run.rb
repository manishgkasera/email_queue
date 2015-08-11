#!/usr/bin/env ruby
require 'email_queue'

# first parameter is app instance specific Id across systems
# second parameter is no of workers to work in parallel.

app = EmailQueue::App.new('AAAAAA', 4)
app.start