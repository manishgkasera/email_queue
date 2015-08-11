Mail.defaults do
  delivery_method :smtp,
                  address: "smtp.gmail.com",
                  port: 587,
                  enable_starttls_auto: true,
                  user_name: 'test@gmail.com',
                  password: '123456',
                  authentication: :plain

end

# other configuration options can be found at
# https://github.com/mikel/mail