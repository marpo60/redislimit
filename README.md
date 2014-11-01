# Request limiter

Proof of concept of a request limiter in Ruby & Redis
[redislimit.marpo60.com](http://redislimit.marpo60.com)

Usage:
* Visit /, here is the table with the amount of visits for each page
* Visit any other page, look at the status code, after 10 request you
  will be banned
* Visit /destroy to clean redis.
