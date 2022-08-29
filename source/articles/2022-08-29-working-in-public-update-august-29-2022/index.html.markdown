---
title: Working in Public Update - August 29, 2022
date: 2022-08-29 9:00 UTC
description:
keywords: working in public
---

I spent the past two weeks in Italy enjoying the sights and sounds and, let's be honest here, tastes that the country has to offer.
<div class="w-full max-w-2xl p-6 mx-auto dark:my-6 dark:bg-white">
  <img src="/images/spaghetti_al_scoglio.jpg" title="Spaghetti al Scoglio, spaghetti with seafood" alt="Spaghetti al Scoglio, spaghetti with seafood" class="w-full" />
</div>

We've been taking our family there for the past 13 years - same town, same apartment, same everything - and it's always been a great source of inspiration as well as a place to catch our breath before the start of school and the final push through the end of the year.
<div class="w-full max-w-2xl p-6 mx-auto dark:my-6 dark:bg-white">
  <img src="/images/sunrise_lido.jpg" title="Sunrise at Lido di Dante" alt="Sunrise at Lido di Dante" class="w-full" />
</div>
READMORE
### What I've been working on

During my time away, I managed to get most of an alpha version of [HuddleUp.dev](https://huddleup.dev/).  It's still pretty rough, but there's enough there to be able to set up a team and upload video stand-up reports that will be displayed on a page that's accessible to all team members.
<div class="w-full max-w-2xl p-6 mx-auto dark:my-6 dark:bg-white">
  <img src="/images/first_huddle.png" title="HuddleUp.dev alpha - team stand-up" alt="HuddleUp.dev alpha - team stand-up" class="w-full" />
</div>

I'd originally planned to build out version 1 of the application as a single-page application in Vue.js.  I originally thought that working directly in Javascript would give me the kind of flexibility and responsiveness that an app like this is going to need and make the path to mobile support with offline capabilities a little easier.  But after talking it over with several friends and feeling the pain of trying to build out code bases for both the front- and back-end as a solo developer, I ditched that approach and opted for a plain, old, boring Rails monolith.  That decision gets most of the credit for being able to bang something together in two weeks worth of mornings.

Digging into a new greenfield Rails project has also meant getting to choose my own tools, and it's been really great getting back to testing in [Minitest](https://github.com/minitest/minitest).  For the past couple of years, most of the testing I've done has been on client projects in [RSpec](https://rspec.info/), and while I can say I've learned quite a bit and that it's changed the way I write tests - some for the better, some for the worse - I like the familiarity and simplicity of having a tiny API that gives me most of what I need without the baggage of having to refer to API docs all the time.

### Goals for this week

I've got semi-hard deadline to finish a bunch of features and tasks for [HuddleUp](https://huddleup.dev/) in the next two weeks, so

- Redesign the current team conversation page to be more "stand-up" like and add a single message detail page.
- Refactor the Javascript for video recording. Right now, It's a bit of a mess.
- Allow users to submit text notes and descriptions along with their videos.
- Choose a platform for deploying of the application. I'd like to find some alternative to Heroku, but that's not a hard requirement.
- Set up staging and production instances, CI, etc.

Between that and client projects and the kids heading back to school this week, work on the updated [Minitest Cookbook](https://chriskottom.com/minitestcookbook/) will need to take a back seat for now.  There just aren't enough hours in the day for everything.
