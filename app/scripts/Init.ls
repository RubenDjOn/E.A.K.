require! {
  'Router'
  'audio/effects'
  'game/Game'
  'game/event-loop'
  'logger'
  'plugins'
  'settings'
  'stats'
  'ui/SettingsView'
  'ui/alert'
}

module.exports = class Init extends Backbone.View
  initialize: ->
    # Check this browser is capable of running EAK
    {compatible, lacking} = @compatible!
    unless compatible
      @$ '#incompatible'
        ..make-only-shown-dialogue!
        ..find 'ul' .html "<li>#{lacking.join '</li><li>'}</li>"
        ..find 'button' .on 'click' ->
          window.session-storage.set-item 'eak-ignore-compatibility' true
          window.location.reload!

      logger.setup lacking
      return

    new SettingsView model: settings, el: $ '#bar-options'

    <~ effects.load!

    <~ logger.setup false
    event-loop.init!

    # Hide the loader and start up the game.
    @$ \.loader .hide-dialogue!

    game = new Game false

    # Start up the Backbone router
    router = new Router!

    Backbone.history.start root: window.location.pathname

  # Uses modernizr to check that all the browser features that EAK requires are present. Returns true
  # if they are, false if not.
  compatible: ->
    Modernizr.addTest 'webaudio', !!window.AudioContext
    if window.session-storage.get-item 'eak-ignore-compatibility' then return {compatible: true, lacking: false}

    needed = <[ csstransforms cssanimations csstransitions csscalc boxsizing canvas webworkers webaudio flexbox ]>
    lacking = _.filter needed, ( not Modernizr. )

    if lacking.length > 0
      console.log 'Lacking:', lacking
      {compatible: false, lacking}
    else
      {compatible: true, lacking: []}
