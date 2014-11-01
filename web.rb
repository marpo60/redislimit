require 'sinatra'
require 'redis'

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)

get '/' do
  REDIS.hgetall("forbidden").to_s
end

get '/*' do
  path = params[:splat].first
  REDIS.hincrby "forbidden", path, 1
end
