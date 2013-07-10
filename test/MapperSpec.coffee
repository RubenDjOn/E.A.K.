describe "game/dom/builder", ->
  Mapper = {}
  el = {}

  expect = chai.expect

  beforeEach ->
    Mapper = require 'game/dom/builder'

    el = document.createElement 'div'
    document.body.appendChild el

    el.setAttribute 'id', 'el'

    el.innerHTML = "Nothing to see here"

  afterEach ->
    el = document.getElementById 'el'
    document.body.removeChild el

    Mapper = {}
    el = {}

  it "should take a DOM element", ->
    mapper = new Mapper el

    expect(mapper.el).to.exist
    expect(mapper.el).to.equal el

  describe "#normaliseStyle", ->
    getStyle = ->
      style = window.getComputedStyle el
      m = new Mapper el
      m.normaliseStyle style

    it "should normalise border-radius", ->
      el.style.width = "500px"
      el.style.height = "500px"
      style = getStyle()
      expect(style.borderRadius).to.equal "0px 0px 0px 0px / 0px 0px 0px 0px"

      el.style.borderTopLeftRadius = "30px"
      style = getStyle()
      expect(style.borderRadius).to.equal "30px 0px 0px 0px / 30px 0px 0px 0px"

      el.style.borderBottomRightRadius = "1.5em"
      style = getStyle()
      expect(style.borderRadius).to.equal "30px 0px 30px 0px / 30px 0px 30px 0px"

      el.style.borderBottomLeftRadius = "10px 20px"
      style = getStyle()
      expect(style.borderRadius).to.equal "30px 0px 30px 10px / 30px 0px 30px 20px"


  describe "#map", ->

    it "should build a map", ->
      mapper = new Mapper el

      mapper.build()

      expect(mapper.map).to.exist
      expect(mapper.map).to.be.an 'array'


    it "should find width and height of rects", ->
      el.innerHTML = "<div style=\"position:absolute; top: 30px;
        left: 200px; width: 100px; height: 40px; background: red;\">boop</div>"

      mapper = new Mapper el

      mapper.build()

      expect(mapper.map).to.deep.equal [
        type: 'rect'
        x: 250
        y: 50
        width: 50
        height: 20
        el: el.children[0]
      ]

    it "should find perfect circles", ->
      el.innerHTML = "
        <div style=\"position: absolute;
          left: 400px;
          top: 500px;
          width: 200px;
          height: 200px;
          border-radius: 100%;\"></div>
        <div style=\"position: absolute;
          left: 200px;
          top: 100px;
          width: 50px;
          height: 50px;
          border-radius: 25px;\"></div>
        <div style=\"position: absolute;
          left: 300px;
          top: 200px;
          width: 60px;
          height: 60px;
          border-radius: 40px;\"></div>"

      mapper = new Mapper el

      mapper.build()

      expect(mapper.map).to.deep.equal [
        type: 'circle'
        x: 500
        y: 600
        radius: 100
        el: (el.querySelectorAll "div")[0]
      ,
        type: 'circle'
        x: 225
        y: 125
        radius: 25
        el: (el.querySelectorAll "div")[1]
      ,
        type: 'circle'
        x: 330
        y: 230
        radius: 30
        el: (el.querySelectorAll "div")[2]
      ]