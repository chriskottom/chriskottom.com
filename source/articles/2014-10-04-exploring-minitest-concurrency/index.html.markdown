---
title: Exploring Minitest Concurrency
date: 2014-10-04 00:00 UTC
description: A look at Minitest's concurrent model for test execution - Minitest::Parallel. How does it work, and what can you expect from it?
keywords: Ruby, Minitest, concurrency, parallelization, testing
---
Among all the other morsels of sunshine and goodness it offers, [Minitest](https://github.com/seattlerb/minitest) gives you the ability to denote that some or all of your test cases are able to run concurrently, and as pointed out in the source comments, that can only mean one thing: that you rule and your tests are awesome.

<div class="w-full max-w-2xl px-6 pb-6 mx-auto dark:pt-6 dark:my-6 dark:bg-white">
  <img src="/images/you_rule_and_your_tests_are_awesome.png" title="In doing so, you're admitting that you rule and your tests are awesome" alt="In doing so, you're admitting that you rule and your tests are awesome" class="w-full" />
</div>

I wanted to better understand how and when to use parallelization in my own code, so I dove into the source and ran some simple bench tests to come up with some guidelines for how to put it to work.READMORE

## The basics

There are two ways to switch on parallelization in your tests. You can apply it to all test cases in your suite by adding the following lines to your `test_helper.rb` file:

```ruby
# test/test_helper.rb

require 'minitest/hell'

class Minitest::Test
  parallelize_me!
end
```

The inclusion of [Minitest::Hell](https://github.com/seattlerb/minitest/blob/master/lib/minitest/hell.rb) ensures that the tests in all cases will be executed in random order by overriding `Minitest::Test.test_order` to return `:parallel`.  (Random test ordering also happens to be the default behavior, but this can be overridden per-test case.)  The call to `parallelize_me!` causes all test cases to queue tests across a pool of concurrent worker threads via the `Minitest::Parallel::Executor` helper class.  The [implementation](https://github.com/seattlerb/minitest/blob/master/lib/minitest/parallel.rb) is worth checking out because it's super simple and does its job nicely - a really great example of restrained, focus code.

It's also perfectly reasonable, though presumably somewhat less awesome, to call `parallelize_me!` only on certain individual test cases when some tests require execution in a strict order.  It's also possible to override global parallelization settings on individual test cases to require serial execution by calling `i_suck_and_my_tests_are_order_dependent!` within the test class.

One additional feature that's not documented anywhere that I could find except in the source code: you can specify the number of worker threads started and run by `Minitest::Parallel::Executor` by providing an environment variable on the command line when you run your tests like so: `N=4 rake test`.  (Minitest defaults to `N=2` if no other value is given.)

## Ruby concurrency vs. Ruby parallelism

There's an important difference between these two concepts that needs to be made clear before moving forward: *concurrency* indicates an ability to manage several tasks, while *parallelism* implies that I can actually **do** multiple things simultaneously.  (Ilya Grigorik summed this up better than I ever could in a [talk](https://www.slideshare.net/igrigorik/no-callbacks-no-threads-cooperative-web-servers-in-ruby-19/13-Concurrency_is_a_myth_in) he gave on the subject.)  As an example, I might be able to juggle lots of chainsaws (excellent concurrency), but I probably can't hold more than one of them at any given time (no parallelism).

<div class="w-full max-w-2xl p-6 mx-auto dark:my-6 dark:bg-white">
  <img src="/images/juggling_chainsaws.jpg" title="Juggling chainsaws" alt="Juggling chainsaws" class="w-full" />
</div>

**In Ruby, whether you achieve parallelism or only concurrency depends on the thread model implemented by the interpreter.**  This is a decision that you the developer make. Minitest can't influence it either way.  Concretely, MRI's thread model maps Ruby Thread objects onto system-level threads, but the Global Interpreter Lock (GIL) ensures thread safety by ensuring that only one is ever allowed to execute at any given time, so parallelism within a single Ruby process is impossible.  Other Ruby implementations - JRuby and Rubinius, as examples - don't have the GIL, and so true parallel execution is possible in both these environments.

Ryan Davis, the author of Minitest, makes no secret about [what Minitest::Parallel was written for](https://www.zenspider.com/ruby/2012/12/minitest-parallelization-and-you.html):

> I don’t care in the slightest about trying to make your tests run faster. You deserve your pain if you write slow tests. What I do care about greatly is making your tests hurt and this will do that.
>
> *- Ryan Davis*

And he's right, of course.  Randomizing the order in which tests are executed gives you a certain measure of confidence that you've managed to write independent tests, and that's the default behavior Minitest provides.  But by then executing tests across multiple threads that don't share state between, you're adding an additional level of isolation insurance.  But why shouldn't we have all of that **and** the fastest possible test execution?  Are there any trade-offs?

## The setup

I set up a base project that consisted of an empty Ruby gem with a basic `Rakefile` and code to generate 1000 tests spread over ten more or less identical test cases which all followed the same pattern:

```ruby
# test/one_fake_test.rb

require "test_helper"

class OneFakeTest < Minitest::Test
  (1..100).each do |i|
    define_method("test_#{ i }") do
      (1..8000).reduce(:*)
      assert(true)
    end
  end
end
```

My goal was to demonstrate test suite performance for three options:

* Baseline - serial execution only
* Minimally parallel - concurrent with two workers
* Maximally parallel - concurrent with eight workers (= number of CPU threads on my development machine)

In order to see how Minitest behaved across different interpreters, I ran the same test using MRI Ruby 2.1.1, JRuby 1.7.9, and Rubinius 2.2.10.

For each implementation and each concurrency level, I executed three test runs and calculated the averages values for suite execution and number of assertions per second as reported by Minitest as well as the total and CPU times reported by the Unix `time` command.  The tables below show the averages along with the relative differences over the baseline (serial) case in parentheses.

## Round 1: MRI

<table class="min-w-full mb-6 border border-sky-300">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <thead class="bg-sky-100 border border-sky-300 dark:text-sky-800">
    <tr>
    	<th></th>
      <th colspan="4" class="px-2 py-1 leading-none">MRI Ruby 2.1.1</th>
    </tr>
    <tr class="header">
      <th class="px-2 py-1 leading-none text-base text-center"></th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(MT)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Assertions/s
      	<br/>
      	<span class="text-sm">(MT)</span>
    	</th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	CPU Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Serial
				<br/>
      	<span class="text-sm">(baseline)</span>
      </th>
      <td class="px-2 py-1 leading-tight text-center">
		    23.42s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    42.71
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    24.06s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    23.81s
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(2 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
		    26.99s
				<br/>
				<span class="text-base">(15.28%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    37.07
				<br/>
				<span class="text-base">(-13.20%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    27.65s
				<br/>
				<span class="text-base">(14.95%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    27.39s
				<br/>
				<span class="text-base">(15.02%)</span>
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(8 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
	    	29.99s
				<br/>
				<span class="text-base">(28.09%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	    	33.34
				<br/>
				<span class="text-base">(-21.93%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	   	  30.66s
				<br/>
				<span class="text-base">(27.45%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	      30.18s
				<br/>
				<span class="text-base">(26.74%)</span>
		  </td>
    </tr>
  </tbody>
</table>

The GIL optimizes for single-threaded execution, so while the additional concurrency might be giving us better assurances that each test is isolated and independent, it's not free.  It's not too painful in this test application, but if I were running a suite for a large, well-covered Rails application where some slower tests are usually unavoidable, I might feel like the added insurance is too expensive.

## Round 2: JRuby

<table class="min-w-full mb-6 border border-sky-300">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <thead class="bg-sky-100 border border-sky-300 dark:text-sky-800">
    <tr>
    	<th></th>
      <th colspan="4" class="px-2 py-1 leading-none">JRuby 1.7.x</th>
    </tr>
    <tr class="header">
      <th class="px-2 py-1 leading-none text-base text-center"></th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(MT)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Assertions/s
      	<br/>
      	<span class="text-sm">(MT)</span>
    	</th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	CPU Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Serial
				<br/>
      	<span class="text-sm">(baseline)</span>
      </th>
      <td class="px-2 py-1 leading-tight text-center">
		    66.18s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    15.11
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    72.12s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    81.96s
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(2 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
		    40.35s
				<br/>
				<span class="text-base">(-39.04%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    26.83
				<br/>
				<span class="text-base">(77.53%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    46.45s
				<br/>
				<span class="text-base">(-35.59%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    95.75s
				<br/>
				<span class="text-base">(16.82%)</span>
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(8 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
	    	17.28s
				<br/>
				<span class="text-base">(-73.90%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	    	58.02
				<br/>
				<span class="text-base">(283.96%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	   	  23.24s
				<br/>
				<span class="text-base">(-67.77%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	      134.28s
				<br/>
				<span class="text-base">(63.83%)</span>
		  </td>
    </tr>
  </tbody>
</table>

My expectations for JRuby were higher because it uses a threading model that allows for fully parallel execution in multicore environments, and I was not disappointed.  Despite being kind of a slow starter, JRuby was able utilize a lot more available CPU when I increased the concurrency, and I was able to run the test suite in about one-third the time.

## Round 3: Rubinius

<table class="min-w-full mb-6 border border-sky-300">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <col style="width: 20%">
  <thead class="bg-sky-100 border border-sky-300 dark:text-sky-800">
    <tr>
    	<th></th>
      <th colspan="4" class="px-2 py-1 leading-none">Rubinius 2.2.x</th>
    </tr>
    <tr class="header">
      <th class="px-2 py-1 leading-none text-base text-center"></th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(MT)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Assertions/s
      	<br/>
      	<span class="text-sm">(MT)</span>
    	</th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	Total Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
      <th class="px-2 py-1 leading-none text-base text-center">
      	CPU Time
      	<br/>
      	<span class="text-sm">(UNIX time)</span>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Serial
				<br/>
      	<span class="text-sm">(baseline)</span>
      </th>
      <td class="px-2 py-1 leading-tight text-center">
		    24.31s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    41.15
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    27.22s
		  </td>
      <td class="px-2 py-1 leading-tight text-center">
		    28.80s
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(2 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
		    16.51s
				<br/>
				<span class="text-base">(-32.07%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    60.61
				<br/>
				<span class="text-base">(47.30%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    19.25s
				<br/>
				<span class="text-base">(-29.29%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
		    35.14s
				<br/>
				<span class="text-base">(22.02%)</span>
		  </td>
    </tr>
    <tr>
      <th class="px-2 py-1 leading-none text-base text-right">
		    Parallel
				<br/>
      	<span class="text-sm">(8 threads)</span>
      </th>
      <td class="px-2 py-1 leading-none text-center">
	    	12.81
				<br/>
				<span class="text-base">(-47.31%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	    	78.10
				<br/>
				<span class="text-base">(89.80%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	   	  15.62s
				<br/>
				<span class="text-base">(-42.62%)</span>
		  </td>
      <td class="px-2 py-1 leading-none text-center">
	      63.42s
				<br/>
				<span class="text-base">(120.18%)</span>
		  </td>
    </tr>
  </tbody>
</table>

Rubinius was the quickest interpreter I tested by a mile.  Even though the performance gains from each additional thread weren't as substantial as I saw in JRuby and tapered off more quickly, the fact is that Rubinius was really nimble, did a good job utilizing multiple cores, and needed about half the startup time of JRuby.  I haven't used Rubinius before, but this experience has convinced me to take a closer look at it in the future.

## The long and short of it

In the end, I learned as much about Ruby and Ruby implementations as I did about Minitest, and so even though this all took some time to think through and set up, it was time well spent.

* Concurrent execution in Minitest isn't just (or even primarily) about speed.  Even with no improvement in performance, the increased test isolation is a worthwhile benefit.
* When using a Ruby implementation that allows for true parallel execution, enable parallel execution with concurrency equal to or approaching the number of available CPU cores on your test system.
* When using MRI Ruby, you'll see the best performance when running in a single thread, but taking a slight performance hit to run concurrently in two threads would probably be a good compromise.

Your mileage may vary when it comes to implementing (or not) concurrent execution within your own real-world tests, but hopefully this will give you a better understanding of how it works in Minitest, what you gain from it, and how to make it work for you.

### Additional resources

* [Minitest Parallelization and You](https://www.zenspider.com/ruby/2012/12/minitest-parallelization-and-you.html) by Ryan Davis
* [No Callbacks, No Threads & Ruby 1.9](https://www.slideshare.net/igrigorik/no-callbacks-no-threads-cooperative-web-servers-in-ruby-19/13-Concurrency_is_a_myth_in) by Ilya Grigorik
* [Concurrency in Ruby Explained](https://matt.aimonetti.net/posts/2011-02-concurrency-in-ruby-explained/) by Matt Aimonetti
* [The GIL and MRI](https://workingwithruby.com/wwrt/gil/) by Jesse Storimer
