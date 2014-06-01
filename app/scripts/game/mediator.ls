require! plugins

# Delay: Utility function for simulating computers that can't run EAK at 60FPS:
delay = (ms) ->
  stop = performance.now! + ms
  while performance.now! < stop => null

class Mediator extends Backbone.Model
  sc = Backbone.Model.prototype
  # Extra event bindings. This allows us to listen on 'eventname:a,b,c'
  # as an alias for 'eventname:a', 'eventname:b' and 'eventname:c',
  # for example. Type is the name of the Backbone.Events function - e.g.
  # `on` and index is the position of the event name - 0 by default,
  # set it to 1 for things like listenTo
  event-modifier = (type, index = 0) ->
    !->
      event = arguments[index]

      # If there's no event, just call super
      if event is undefined
        sc[type].apply @, arguments
        return

      # Backbone events are in the format 'event:specific'. We're interested
      # in the `specific` part
      e = event / ':'

      if e.length is 1
        sc[type].apply @, arguments
        return

      specifics = e.1 / ','

      if specifics.length is 1
        sc[type].apply @, arguments
        return

      # If we've got more than one specific, call the function for all of them
      for specific in specifics
        arguments[index] = "#{e.0}:#specific"
        sc[type].apply @, arguments

  # Override events from Backbone.Events with our modified ones
  on: event-modifier \on
  off: event-modifier \off
  trigger: event-modifier \trigger
  once: event-modifier \once
  listen-to: event-modifier \listenTo 1
  stop-listening: event-modifier \stopListening 1
  listen-to-once: event-modifier \listenToOnce 1

# Everything else is on a specific instance of mediator:
mediator = new Mediator!

# jQuery usefulness
$window = $ window
$doc = $ document
$body = $ document.body

# mediator.paused stops frame and key events from being triggered when true
mediator.paused = false

# You can trigger events using hyperlinks. Use `event:` instead of `http:`
$ document .on \tap '[href^="event:"]' (e) ->
  e.prevent-default!
  e.stop-propagation!

  ev = $ e.target .attr \href .substr 'event:'.length
  mediator.trigger ev

# The `alert` event triggers a notification. These are loosely based on OSX
# notifications. TODO: make notifications resize to fit their content.
# Animation etc. is handled all in CSS.
$notification-container = $ '<div></div>'
  ..add-class \notification-container
  ..append-to $body

mediator.on \alert (msg) ->
  $alert = $ '<div></div>'
    ..add-class \notification
    ..prepend-to $notification-container

  $inner = $ '<div></div>'
    ..add-class \notification-inner
    ..text msg
    ..append-to $alert

  # Notifications are hidden after 5 seconds
  <- set-timeout _, 5000ms
  $alert.add-class \hidden

  <- $alert.on animation-end
  $alert.remove!

# Trigger events for taps/clicks that aren't caught elsewhere
$doc.on \tap -> unless mediator.paused then mediator.trigger \uncaughtTap

# Debugging. The 'b' key is used to toggle debug info. When it is enabled, frame
# information is shown, and all triggered events apart from the ignored ones are
# logged to the console.
mediator.DEBUG-enabled = false
mediator.DEBUG-el = $ '.debug-data'
DEBUG-ignored-events = <[ frame postframe playermove ]>

mediator.on \all (name, data) ->
  if mediator.DEBUG-enabled and name not in DEBUG-ignored-events
    console.log name, data

mediator.on \keypress:b ->
  mediator.DEBUG-enabled = not mediator.DEBUG-enabled
  mediator.trigger \DEBUG-toggle mediator.DEBUG-enabled

mediator.on \DEBUG-toggle (dbg) ->
  mediator.DEBUG-el.css \display if dbg then \block else \none

# FPS monitor. The 'f' key turns on the fps meter:
mediator.once \keypress:f ->
  stats = mediator.stats = new Stats!
  stats.set-mode 0
  stats.dom-element.style <<< position: 'absolute', bottom: 0, right: 0
  document.body.append-child stats.dom-element

  mediator.on \preframe ->
    stats.begin!
    # Slow things right down for testing
    # delay 50

  mediator.on \postframe ->
    stats.end!

# Key events
# Us the names of non alpha-numeric keys
keydict = do
  8: \backspace, 9: \tab, 13: \enter, 16: \shift, 17: \ctrl,
  19: \pausebreak, 18: \alt, 20: \capslock, 27: \escape, 32: \space, 33: \pageup,
  34: \pagedown, 35: \end, 36: \home, 37: \left, 38: \up, 39: \right,
  40: \down, 45: \insert, 46: \delete

$window.on 'keypress keyup keydown' (e) ->
  code = keydict[e.which] or (String.from-char-code e.which .to-lower-case!)

  unless mediator.paused
    mediator.trigger e.type
    mediator.trigger "#{e.type}:#code" e

module.exports = mediator
