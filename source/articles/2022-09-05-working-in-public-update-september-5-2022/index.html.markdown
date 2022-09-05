---
title: Working in Public Update - September 5, 2022
date: 2022-09-05 00:00 UTC
description: Last week, I set up deployment and CI for the app and invested in learning more about Stimulus and Hotwire. Heading into this week, I'm thinking about how to make HuddleUp sustainable to build and operate as a solo founder.
description: This week I set up application instances and continuous integration and learned enough Hotwire and Stimulus to be dangerous.
keywords: working in public
---

## What I've been working on

I spent a lot of time last week investing in areas that I think will help me go faster as I build out [HuddleUp](https://huddleup.dev/) over the next weeks and months, so even though I didn't cross as many items off the to-do list as I would have liked, I'm still pleased with the output.

I spent a few hours at the beginning of the week setting up continuous integration on the code repository using Github Actions with deployment to staging and production application instances.  This included all the usual tasks like:

- Setting up application instances and a pipeline connecting them
- Automating deployments conditional on successful running of the test suite and static analysis tools
- Installing SSL certificates and setting up DNS records
- Adding and configuring all necessary add-ons and tools
- Getting the application successfully deployed and running

I had been hoping to use some Heroku alternative right from the start, but in the end, I decided to go with what I know rather than trying to learn a completely new system.

I also spent several hours working my way through [The Pragmatic Studio's course on Hotwire and Stimulus](https://pragmaticstudio.com/courses/hotwire-rails).  Again, this is something that's not usable code and features, but I think it's going to help me build faster and more sustainably over the coming months.

As an aside, I **highly recommend** this course.  As an old-school Rails developer, I resisted wading into this new way of building applications for a long time thinking that it was a half-measure designed to provide an answer to the JavaScript client framework wave.  Having dug into it now, I see that it isn't some slapped-together, tacked-on afterthought but rather a completely different way of looking at web application development that doesn't require learning and maintaining two complete technology stacks and code bases.  The course lays out how all the various technologies work with one another and form a coherent whole that's better than other alternatives I've tried.

I also managed to spend about a half-day working on refactoring the interface and JavaScript for recording video stand-up updates.  It's still a work in progress, and some of the stuff I'm trying to do, even in a v1, is proving challenging, but if there's one thing I've always been able to do, it's stay in the chair until the damn thing works.

<div class="w-full max-w-2xl p-6 mx-auto dark:my-6 dark:bg-white">
  <img src="/images/video_message_work_in_progress.png" title="Video stand-up update - work in progress" alt="Video stand-up update - work in progress" class="w-full" />
</div>

## Goals for this week

I'm still hoping to have a demoable version of [HuddleUp](https://huddleup.dev/) ready and deployed by the middle of next week, so I'm going to be focusing on core feature development and improvements this week.  That means getting the rest of the JS working on the video stand-up entry page and adding the ability to include text notes (probably in Markdown format) alongside the video updates.

I also want to make update the main team conversation in order to group each day's updates as a single virtual stand-up as a way of simplifying it as well as putting some of the Turbo and Hotwire tricks I picked up last week into practice and possibly enabling push updates to the page with Action Cable.

## Deep thoughts I'm thinking

Probably one of the biggest concerns I have about working on a project like this as a solo founder is that there won't be enough of me to go around.  Having seen bootstrapped SaaS companies from the inside, either directly or indirectly, the whole nightmare scenario where something goes wrong and everyone is screaming at you or demanding refunds isn't an everyday occurrence.  It's actually extremely rare, but when it does eventually happen, as a person who hates to disappoint anyone ever, one of my biggest concerns about this has always been that I wouldn't be able to rise to the occasion and deal with it.

The question on my mind for the past several weeks has been: how can I design and implement the business and the application such that the risk of such an event is minimized and at least solvable by a single person when it does happen?  The solution will probably emerge at various steps in the process as I bring more customers onto the platform - going from zero customers to one, going from 4 customers to 5, going from 20 to 30 customers, and so on.

Hit me up on [Twitter](https://twitter.com/chriskottom) if you think you've got any insights or practical know-how.
