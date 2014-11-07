require 'sinatra'
require 'haml'
require 'redis'

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)

class Visit
  attr_reader :path, :count, :ttl

  def self.all
    visits = []
    keys = REDIS.keys("visits_*")
    keys.each do |key|
      visits << find(key.gsub("visits_",""))
    end

    visits
  end

  def self.destroy_all
    REDIS.flushdb
  end

  def self.find(path)
    key = "visits_#{path}"
    count = REDIS.get(key).to_s
    ttl = REDIS.ttl(key).to_s
    Visit.new(path, count, ttl)
  end

  def initialize(path, count, ttl)
    @path = path
    @count = count.to_i
    @ttl = ttl
  end

  def increase_counter
    key = "visits_#{path}"
    REDIS.incr(key)
    @count = @count + 1
    if @count == 1
      REDIS.expire(key, 60)
    end
  end
end

get '/' do
  template = Tilt.new "templates/index.html.haml"
  template.render(self, visits: Visit.all)
end

get '/favicon.ico' do
  200
end

get '/destroy' do
  Visit.destroy_all
end

def limit_page_visit(path)
  visit = Visit.find(path)
  visit.increase_counter
  visit.count > 9
end

get '/*' do
  if limit_page_visit(params[:splat].first)
    429
  else
    200
  end
end
