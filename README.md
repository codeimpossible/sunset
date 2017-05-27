# Sunset plugin for Atom

Change your UI and Syntax themes based on the time of day!

## Installation

Using `apm`:

```
apm install sunset
```

Or search for `sunset` in Atom settings view.

## Setup
By default, sunset doesn't start working until you configure the themes. I did this because I didn't want people who installed sunset to have their themes blown away immediately.

**Pick the UI and Syntax themes you want to use during Daytime and Nighttime.** You'll have to enter the theme names manually for now (until i build out a configuration view). After you set the daytime and nighttime themes sunset will begin working.

**Then enter the times of Sunrise and Sunset in 24 hour format.** The defaults are daytime at 5am and nighttime at 6pm.

**You're all set!**


### Publishing a release of sunset

Because I don't do this very often, here are the steps to release a new version of sunset.

- make sure all the changes are merged to master
- CHANGELOG should have the notes for the version in it already
- run `$ apm publish <version>` or `$ apm publish major | minor | patch`
