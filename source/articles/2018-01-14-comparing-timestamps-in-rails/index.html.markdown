---
title: Comparing Timestamps in Rails
date: 2018-01-14 00:00 UTC
last_updated: 2022-03-16 13:53 UTC
---
The Ruby core language and standard library include two classes that represent timestamps: Time and DateTime.  And even though they fill similar needs, they have different internals and aren't comparable.

```ruby
irb(main):001:0> require 'date'
true
irb(main):002:0> time = Time.now
2018-01-14 16:40:29 +0100
irb(main):003:0> datetime = DateTime.now
#<DateTime: 2018-01-14T16:40:40+01:00 ((2458133j,56440s,60191240n),+3600s,2299161j)>
irb(main):004:0> time < datetime
ArgumentError: comparison of Time with DateTime failed
		from (irb):5:in `<'
		from (irb):5
		from /home/chris/.rbenv/versions/2.4.2/bin/irb:11:in `<main>'
```
READMORE
Rails adds the `ActiveSupport::TimeWithZone` class and extends the core classes in a number of ways including by allowing comparison of instances of different classes:

```ruby
irb(main):005:0> require 'active_support'
=> true
irb(main):006:0> require 'active_support/core_ext'
=> true
irb(main):007:0> time = Time.now
=> 2018-01-14 16:43:18 +0100
irb(main):008:0> datetime = DateTime.now
=> Sun, 14 Jan 2018 16:43:24 +0100
irb(main):009:0> time < datetime
=> true
irb(main):010:0> Time.zone = 'Eastern Time (US & Canada)'
=> "Eastern Time (US & Canada)"
irb(main):011:0> time_with_zone = Time.zone.now
=> Sun, 14 Jan 2018 10:44:10 EST -05:00
irb(main):012:0> date < time_with_zone
=> true
```

In most cases, this frees you up to write code without having to explicitly convert between types or even know which types you're comparing.  But eventually you might find yourself try to test the equality of two timestamps which should logically be the same:

```ruby
assert_equal email.sent_at, email_delivery.created_at
```

The error message in this case only deepens the mystery:

```
No visible difference in the ActiveSupport::TimeWithZone#inspect output.
You should look at the implementation of #== on ActiveSupport::TimeWithZone or its members.
Sun, 14 Jan 2018 11:13:40 EST -05:00
```

The thing to remember here is that all of these classes store timestamps with much more precision than they usually display.  In the case of `ActiveSupport::TimeWithZone`, that goes down to millisecond and even nanosecond precision.

```ruby
irb(main):013:0> time_with_zone.to_s
=> "2018-01-14 10:44:10 -0500"
irb(main):014:0> time_with_zone.to_i
=> 1515944650
irb(main):015:0> time_with_zone.to_f
=> 1515944650.4874508
irb(main):016:0> time_with_zone.usec
=> 487450
irb(main):017:0> time_with_zone.nsec
=> 487450777
```

So when we want to compare timestamps that we know to be unequal, the usual operators (`>`, `<`, …) are fine.  But if we're checking for relative equality, we'll need to use some representations of the timestamps.

In [The Minitest Cookbook](https://chriskottom.com/minitestcookbook/) I advised developers to compare dates and times using a string representation since, when you do fail a test, the message returned will usually be meaningful.

```ruby
send_time = email.sent_at
assert_equal "2017-11-02 17:09", send_time.strftime("%Y-%m-%d %H:%M")
```

I still think that's the way to go when you're comparing generated data with a constant value, but in other cases like where you're checking the equality of two generated values, it's usually better to compare numeric representations of the timestamps as:

```ruby
send_time = email.sent_at
delivery_time = email.delivery.created_at
assert_equal send_time.to_i, delivery_time.to_i
```

Keep in mind that there's always the chance that the two timestamps might be generated across a second boundary which would cause the test as written to fail.  If you're looking for some additional insurance for this situation, you could also assert that the numeric representations of the timestamps are within a delta of one another:

```ruby
send_time = email.sent_at
delivery_time = email.delivery.created_at
delta = 0.01
assert_in_delta send_time.to_f, delivery_time.to_f, delta
```
