# frozen_string_literal: true

module CONSTANTS
  JWT_ALGORITHMS_TYPE = ENV['JWT_ALGORITHMS_TYPE']
  JWT_SECRET_KEY = ENV['JWT_SECRET_KEY']
  JWT_ISS = ENV['JWT_ISS']
  JWT_EXPIRATIONTIME = (ENV['JWT_EXPIRATIONTIME'] || '3600').to_i
  THREAD_COUNT = (ENV['RAILS_THREAD_COUNT'] || '4').to_i
end

# PostgreSQL optimization
module RDBMS
  SERIAL_PRIMARY_KEY = 'SERIAL PRIMARY KEY'.freeze
  TIMESTAMP_WITH_TIMEZOE = 'timestamp with time zone'.freeze
end

module HTTP
  ACCESS_CONTROL_ALLOW_METHODS = %w[GET OPTIONS].freeze
  ACCESS_CONTROL_ALLOW_HEADERS = %w[Accept Origin Content-Type Authorization].freeze
  ACCESS_CONTROL_MAX_AGE = 86400
end
