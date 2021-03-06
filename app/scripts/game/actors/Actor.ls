module.exports = class Actor extends Backbone.View
  @from-el = ($el, args, offset) -> new Actor el: $el.0, args: args, offset: offset

  physics-ignore: true

  initialize: (start = {x: 0, y: 0}) ->
    @subs = []
    @start = start
    @args = start.args if start.args
    @origin = start.{x, y}
    @offset = start.offset or {x: 0, y: 0}
    width = @$el.width!
    height = @$el.height!

    if @physics-ignore then @$el.attr \data-ignore true
    @$el.css {
      position: \absolute
      left: start.x - width / 2
      top: start.y - height / 2
    }

    # Data for physics
    this <<< {
      type: \rect
      x: start.x
      y: start.y
      width: width
      height: height
      rotation: 0
      data: {}
    } <<< (@physics or {})

    @data.id = "ENTITY_#{@actor-type!to-upper-case!}"
    @data.actor = true

  actor-type: -> Object.get-prototype-of this .constructor.display-name.to-lower-case!

  reset: (origin = @origin) ~>
    @ <<< {
      x: origin.x
      y: origin.y
      rotation: 0
      prepared: false
    }

    @$el.css {
      left: origin.x - @width/2
      top: origin.y - @height/2
    }

    @prepare!

  remove: ~>
    super!
    for sub in @subs => sub.unsubscribe!

  draw: ->
    @$el.css prefixed.transform, "translate3d(#{@p.x - @x - @offset.x}px, #{@p.y - @y - @offset.y}px, 0)"
