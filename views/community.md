Community
===

* Join the [mailing list](http://groups.google.com/group/redis-db) (Subscribe via [mail](mailto:redis-db+subscribe@googlegroups.com))
* Meet us at the `#redis` channel on Freenode ([web access link](http://webchat.freenode.net/?channels=redis))
* Follow [Salvatore](http://twitter.com/antirez) on Twitter

Local meetups
---

* [London Redis Meetup Group](http://www.meetup.com/Redis-London)
* [San Francisco Meetup Group](http://sfmeetup.redis.io)

Contributing to Redis
---

Would you like to contribute a feature to Redis?

1. Enter the IRC channel `#redis` on Freenode and look for Salvatore (antirez) or Pieter (pietern).
Ask them what they think about your idea and what the chances are of getting it merged upstream.
We try hard to keep Redis simple, so you're likely to find high resistance to new features.

2. If you don't get any feedback, or if feedback is positive, drop a message to the
[mailing list](http://groups.google.com/group/redis-db) with your proposal. Make sure you explain
what the use case is and how the API would look like.

3. If you get good feedback, do the following to submit a patch:

    1. Fork [the official repository](http://github.com/antirez/redis).
    2. Clone your fork: `git clone git@github.com:<your-username>/redis.git`
    3. Make sure tests are passing for you: `make && make test`
    4. Create a topic branch: `git checkout -b new-feature`
    5. Add tests and code for your changes.
    6. Once you're done, make sure all tests still pass: `make && make test`
    7. Commit and push to your fork.
    8. [Create an issue](http://code.google.com/p/redis/issues/entry) with a link to your patch.
    9. Sit back and enjoy.

There are other ways to help:

* [Fix a bug](http://code.google.com/p/redis/issues/list?can=2&q=status%3AAccepted)

* Improve the [documentation](http://github.com/antirez/redis-doc)

* Help maintain or create new [client libraries](/clients)

* Improve [this very website](http://github.com/antirez/redis-io)
