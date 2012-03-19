IntegrationTestRedis
====================

Provide a non-persistent [Redis](http://redis.io/) server for use in integration tests.

Why?
----

Many redis test solutions work by completely mocking out the Redis client
interface.  This is sometimes a good approach, especially if you want to
write pure unit tests.  However, there are times you want to integrate
with Redis safely for testing purposes.

Testing against a running Redis server instance can be tricky.  Since Redis
supports a few numeric database ids, knowing where it's safe to tread
during tests is iffy.  This is especially true when writing tests that
integrate through to the service inside a public gem.  One errant
`redis.flushdb` and you might have just dropped some cherished data on
behalf of a user.  That is, not good.

How?
----

The IntegrationTestRedis class provides `start`, `stop`, and `client` methods
to get at a Redis setup suitable for integration testing.  It starts a running,
non-persistent server for you.

Usage
-----

```ruby
require "integration_test_redis"
# Start the server
IntegrationTestRedis.start
# Get a suitable client to the server
redis_client = IntegrationTestRedis.client
# Stop the server.  Also handled automatically in an at_exit callback
IntegrationTestRedis.stop
```

Thanks
------

This code was extracted from the work of various individuals to the
[Likeable](https://github.com/schneems/likeable) codebase.

#### Copyright

Copyright (c) (2011) Brendon Murphy. See LICENSE for details.
