# Turku street maintenance map

Adaptation of [Aurat kartalla](http://www.auratkartalla.com/) to Turku region. This app is running at https://dev.turku.fi/maintenance-map/

This data visualization shows an a map information about street maintenance jobs in the Turku region. The GPS data is collected by [Kuntec](http://www.kuntec.fi). Data is collected only from a portion of all vehicles.

I'm using [Sass](http://sass-lang.com/) with [Compass](http://compass-style.org/) to precompile CSS and [CoffeeScript](http://coffeescript.org/) for JS. I suggest you learn these at [Code School](http://codeschool.com/) ([CoffeeScript](http://coffeescript.codeschool.com/), [Sass](https://www.codeschool.com/courses/assembling-sass)). Front-end is done with [Lo-Dash](https://lodash.com/) and jQuery. This app doesn't have a back-end besides [the Street maintenance API](https://github.com/City-of-Turku/street-maintenance-api).

## How to
    gem install compass && npm install -g coffee-script (Sass 3.4.9 and Compass 1.0.1 tested, Coffee at 1.8.0)
    compass watch .
    coffee -cwo js/ coffee/main.coffee
    Launch a server (for example: python -m SimpleHTTPServer 8000)
    Open in browser: http://localhost:8000/index.html

## Licence
Licence is GPL v3. Please remember attribution and drop original author Sampsa a line: [@sampsakuronen](https://twitter.com/sampsakuronen)
