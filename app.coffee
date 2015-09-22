$ = require 'jquery'
EventEmitter = require 'node-event-emitter'
Promise = require 'bluebird'
React = require 'react'
require 'react/addons'
_ = require 'lodash'
window.React = React

React.addons.Perf.start()

_c = React.createClass
_e = React.createElement

Pixel = _c
    displayName: "Pixel"
    getDefaultProps: ->
        height: "10px"
        width: "10px"
        color: [0,255,0]
    #shouldComponentUpdate: (newProps)->
        #true
        ##newProps.selected isnt @props.selected
    componentDidUpdate: ->
        
    selectMe: ->
        @props.onSelect @props.coords[0], @props.coords[1]
    render: ->
        switch (typeof @props.color)
            when "number"
                c = [@props.color, @props.color, @props.color].map Math.floor
                letter = ""
            when "string"
                c = [ 255,255,255 ]
                letter = @props.color
            when "undefined"
                c = [ 255,255,255 ]
                letter "u"
            when "object"
                c = @props.color
                letter = ""
            else
                console.log "alert: ", typeof @props.color

        #c = @props.color
        {div} = React.DOM
        div
            #onMouseOver: @selectMe
            onClick: => @props.handleClick @props.coords
            style:
                height: @props.height
                width: @props.width 
                border: if @props.selected then "1px solid black"
                #borderRadius: "50%"
                backgroundColor: "rgb(#{c[0]},#{c[1]},#{c[2]})"
            , letter

b = 0 
w = 255

imgsData = 
    smiley: [
        [w,w,b,b,b,b,w,w]
        [w,b,w,w,w,w,b,w]
        [b,w,b,w,b,w,w,b]
        [b,w,b,w,b,w,w,b]
        [b,w,w,w,w,b,w,b]
        [b,w,b,b,b,w,w,b]
        [w,b,w,w,w,w,b,w]
        [w,w,b,b,b,b,w,w]
    ]

Matrix = _c
    render: ->
        {table, tr, td} = React.DOM
        table 
            style:
                border: "1px solid black"
                borderCollapse: "collapse"
            , @props.rows.map (r, i) ->
                tr {key: i}
                , r.map (x, j) ->
                    td
                        style:
                            border: "1px solid black"
                            textAlign: "center"
                            padding: "2px"
                        key: j
                    , x

Image = _c
    displayName: "Image"
    getInitialState: ->
        {selectedPixel: undefined}
    selectPixel: (pixelCoords) ->
        @setState {selectedPixel: pixelCoords}
    render: ->
        {p, div, table, tr, td} = React.DOM
        div null,
            (
                table {style:{borderSpacing: "0px"}},
                    @props.rows.map (x, i) =>
                        tr {key: i}, x.map (y, j) =>
                            td {key: j}, 
                                _e Pixel, 
                                    className: "pixel"
                                    handleClick: @props.handleClick
                                    color: y
                                    height: @props.pixelHeight
                                    width: @props.pixelWidth
                                    coords: [i,j] 
                                    onSelect: => @selectPixel [i, j]
                                    selected: _.isEqual @props.selectedPixel, [i,j]
            )
            , p null, @state.selectedPixel
            

loadSubImg = (src, x, y, h, w) ->
    img = $('<img src="' + src + '">')
    new Promise (fulfill, reject) ->
        img.on "load", -> 
            x = x or 0
            y = y or 0
            w = w or img[0].width
            h = h or img[0].height
            canvas = document.createElement "canvas" 
            context = canvas.getContext "2d"
            canvas.height = img[0].height 
            canvas.width = img[0].width
            context.drawImage img[0], 0, 0 
            data = context.getImageData x, y, w, h
            pixels = _.chunk data.data, 4
            rows = _.chunk pixels, w or img.width
            fulfill rows

# this is the component modifyiable prototype
# it should have an element, a state, a console, some methods that
# act upon the state

Console2 = _c
    getInitialState: -> {commands: []}
    enter: ->
        text = React.findDOMNode(@refs.text).value
        @setState {commands: @state.commands + [text]}
        @props.onEnter text 

    map: ->
        text = React.findDOMNode(@refs.text).value
        @props.onMap text 

    render: ->
        {div, textarea, p, button} = React.DOM
        div null,
            #(p null,
                #@state.commands
            #)
            (textarea
                style:
                    resize: "none"
                    height:"5em"
                    width:"100%"
                    display: "block"
                    fontFamily: "monospace"
                onChange: @props.onChange
                ref: "text"
                onKeyDown: (e) =>
                    if e.keyCode is 13
                        @props.onShiftEnter? e)
            , _.keys(@props.buttons).map (k) =>
                (button
                    key: k
                    style:
                        marginTop:10
                        marginBottom:10
                    onClick: @props.buttons[k]
                    , k)

Console = _c
    getInitialState: -> {commands: []}
    enter: ->
        text = React.findDOMNode(@refs.text).value
        @setState {commands: @state.commands + [text]}
        @props.onEnter text 

    map: ->
        text = React.findDOMNode(@refs.text).value
        @props.onMap text 

    render: ->
        {div, textarea, p, button} = React.DOM
        div null,
            #(p null,
                #@state.commands
            #)
            (textarea
                style:
                    height:"5em"
                    width:"100%"
                    display: "block"
                    fontFamily: "monospace"
                onChange: @props.onChange
                ref: "text"
                onKeyDown: (e) =>
                    if e.keyCode is 13
                        @props.onShiftEnter? e)
            , (button
                style:
                    marginTop:10
                    marginBottom:10
                onClick: @enter
                , "vai")
            , (button
                onClick: @map
                , "map")

ImageCanvas = _c
    draw: ->
        canvas = React.findDOMNode @refs.canvas
        context = canvas.getContext "2d"
        pixels = _.flatten @props.rows
        toRGBA = (pixel) ->
            switch (typeof pixel)
                when "number"
                    [pixel,pixel,pixel,255]
                when "letter"
                    [255,255,255,1]
                when "object"
                    [pixel[0],pixel[1],pixel[2],255] 
                else
                    [0,0,255,255]
        pixels = _.flatten (pixels.map toRGBA)
        height = @props.rows.length
        width = @props.rows[0]?.length
        imgdata = context.createImageData(width, height)
        pixels.map (x, i) -> imgdata.data[i] = x 
        context.putImageData imgdata, 0, 0
    componentDidUpdate: -> 
        @draw()
    componentDidMount: ->
        @draw()
    render: ->
        {canvas} = React.DOM
        canvas 
            ref: "canvas"
            height: @props.rows.length
            width: @props.rows[0]?.length

SS = class extends EventEmitter

    constructor: (rows) ->
        @state = {rows: rows}

    commitState: ->
        @emit "change"

    exec: (cmd) ->
        img = this
        try
            res = (eval cmd)
            @commitState()
            return res
        catch e
            @emit "error", e

    invertPixel: (x, y) ->
       @state.rows[x][y] = Math.abs (255- @state.rows[x][y])
       @commitState()

    map: (cmd) -> 
            img = this
            try
                @state.rows.map (r, i) =>
                    r.map (x, j) =>
                        img.selectPixel j, i
                        (eval cmd)
                        #img.setPixel(img.getPixel()[0])
                @commitState()
            catch e
                @emit "error", e 

    selectPixel: (x,y) ->
        img = this
        @state.selectedPixel = [x,y]
        @state.pickedColor =  @state.rows[y][x]
        undefined

    getPixel: ->
        img = this
        [x, y] = @state.selectedPixel
        @state.rows[y][x]

    setPixel: (rgb) ->
        @state.rows[@state.selectedPixel[1]][@state.selectedPixel[0]] = rgb

    

$("my-image").each ->
    cns = document.createElement "console"
    img = document.createElement "image"

    $(this).append cns
    $(this).append img

    rows = imgsData[this.dataset.data]

    ss = new SS(rows)

    render = =>
        React.render (_e Image, {
            handleClick: ((coords) -> ss.invertPixel coords[0], coords[1]),  
            selectedPixel: ss.state.selectedPixel
            rows: ss.state.rows}), img

    if this.dataset.console
        $(this).append cns
        React.render (_e Console, 
            onEnter: (x) -> 
                ss.exec x
            onMap: (x) ->
                ss.map x
        ), cns
    ss.on "change", -> 
        render()
    render()

createPhotoshop = (renderer, box, elem) ->
    cnsole = document.createElement "console"
    canvas = document.createElement "my-image"
    $(elem).append cnsole
    $(elem).append canvas

    ss = new SS()
    canvasRender = ->
        React.render (_e renderer, {pixelHeight: "5px", pixelWidth: "5px", rows: ss.state.rows, selectedPixel: ss.state.selectedPixel}), canvas

    ss.on "change", ->
        canvasRender()

    loadSubImg("imgs/sunday_seurat.jpg",box.x,box.y,box.w,box.h,100)
        .then (rows) =>
            ss.state.rows = rows
            ss.commitState()
    
    React.render (_e Console,
        onEnter: (cmd) ->
            ss.exec cmd
            ss.commitState()
        onMap: (cmd) ->
            ss.map cmd
    ), cnsole

$("sub-img").each ->
    createPhotoshop Image, {x:0, y:0, h:100, w:100}, this

$("my-canvas").each ->
    createPhotoshop ImageCanvas, {}, this

module.exports =
    createPhotoshop: createPhotoshop
    React: React
    SS: SS
    _e: _e
    Console: Console
    Console2: Console2
    Image: Image
    ImageCanvas: ImageCanvas
    $: $
    _: _
    imgsData: imgsData
    FontAwesome: require 'react-fontawesome'
    loadSubImg: loadSubImg
    Matrix: Matrix
