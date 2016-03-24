$ = require 'jquery'
EventEmitter = require 'node-event-emitter'
Promise = require 'bluebird'
React = require 'react'
Reflux = require 'reflux'
require 'react/addons'
_ = require 'lodash'
window.React = React

React.addons.Perf.start()

_c = React.createClass
_e = React.createElement

resetConsole = Reflux.createAction()
setLastCommand = Reflux.createAction()
selectPixel = Reflux.createAction()
setPixel = Reflux.createAction()

hintize = ->
    hintsLen = $(".hint").length
    $(".hint").each (index) ->
        $(@).wrap $("<div></div>").css({position: "relative"})

        label = $("<div>")
            .addClass "hint-label"
            .text("Suggerimento #{if hintsLen > 1 then index+1 else ''}")

        $(@).before label
        $(@).css {"opacity":0.07, "background-color":"grey"}
        elem = $(@)
        label.click ->
            elem.css "background-color", "white"
            label.css {visibility:"hidden"}
            label.animate {opacity:0}, 0, ->
                elem.animate
                        opacity: 1
                        "background-color": "white"
                    , 200 

modal = (elem) ->

    show = -> 
        elem.css "visibility", "visible"
        elem.animate {opacity:0.95, 0.2}

    close = ->
        elem.animate {opacity:0}, 0.2, ->
            elem.css "visibility", "hidden"

    elem.find(".close").click close

    return {show, close}

LastCommandDisplay = _c 
    render: -> _e "p",
        style:
            fontFamily: "monospace"
    , @props.text 

Pixel = _c
    displayName: "Pixel"
    getDefaultProps: ->
        height: "10px"
        width: "10px"
        color: [0,255,0]

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

ErrorDisplay = _c
    render: ->
        _e "p",
            style:
                color: "red"
            , @props.error?.toString()

Console2 = _c
    getInitialState: -> {commands: [], text: ""}
    componentDidMount: ->
        resetConsole.listen =>
            @setState {text: ""}

    getInitialState: -> {commands: []}
    handleTextChange: (e) ->
        @setState {text: e.target.value}
    enter: ->
        text = React.findDOMNode(@refs.text).value
        @setState {commands: @state.commands + [text]}
        @props.onEnter text 

    map: ->
        text = React.findDOMNode(@refs.text).value
        @props.onMap text 

    render: ->
        {div, input, textarea, p, button} = React.DOM
        div {style: {width: "100%"}}, [
            (_e ErrorDisplay, {error: @props.error})
            , (_e LastCommandDisplay, 
                text: @props.lastCommand)
            , (input
                type: "text"
                style:
                    resize: "none"
                    width:"100%"
                    display: "block"
                    fontFamily: "monospace"
                    length: "100%"
                    fontSize: "14px"
                    padding: "10px"
                    
                onChange: (e) => 
                    @handleTextChange e
                    @props.onChange e
                ref: "text"
                value: @state.text
                onKeyDown: (e) =>
                    if e.keyCode is 13
                        @props.onShiftEnter? e
                    if e.key is "ArrowUp"
                        @setState {text: @props.lastCommand}
            ) if not @props.noInput
            , _.keys(@props.buttons).map (k) =>
                (button
                    key: k
                    style:
                        marginTop:10
                        marginBottom:10
                    onClick: @props.buttons[k]
                    , k)
        ]


Modal = _c

    getInitialState: -> 
        text: undefined

    componentDidMount: ->
        @props.showMessageAction.listen? (text) =>
            @setState {text}

    render: ->
        React.DOM.p {}, @state.text

Console = _c
    getInitialState: -> {commands: [], text: ""}

    componentDidMount: ->
        resetConsole.listen =>
            @setState {text: ""}
            

    enter: ->
        text = React.findDOMNode(@refs.text).value
        @setState {commands: @state.commands + [text]}
        @props.onEnter text 

    map: ->
        text = React.findDOMNode(@refs.text).value
        @props.onMap text 

    handleTextChange: (e) ->
        @setState {text: e.target.value}

    render: ->
        {div, textarea, p, button} = React.DOM
        div null,
            #(p null,
                #@state.commands
            #)
            (_e "input",
                type:"text"
                style:
                    height:"5em"
                    width:"100%"
                    display: "block"
                    fontFamily: "monospace"
                onChange: (e) =>
                    @handleTextChange e
                    @props.onChange e
                ref: "text"
                onKeyDown: (e) =>
                    if e.keyCode is 13
                        @props.onShiftEnter? e
                value: @state.text 
            )
            , (button
                style:
                    marginTop:10
                    marginBottom:10
                onClick: @enter
                , "vai")
            , if @props.map
                (button
                    onClick: @mapV
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


            #@props.text? || ""

SS = class extends EventEmitter

    constructor: (rows) ->
        @state = {rows: rows}
        @state.original_rows = _.cloneDeep rows

        resetConsole.listen =>
            @state.command = ""

        setLastCommand.listen (cmd) =>
            @state.lastCommand = cmd
            @emit "change"

        selectPixel.listen ([x, y]) =>
            @state.selectedPixel = [x, y]
            @state.pickedColor = @state.rows[x][y]
            @emit "change"

        setPixel.listen (rgb) =>
            @setPixel @selectedPixel, rgb

    resetRows: =>
        @state.rows = _.cloneDeep @state.original_rows
        @state.selectedPixel = null
        @emit "change"

    serializeState: (fields = -> true) =>
        JSON.stringify _.pick @state, fields

    deserializeState: (str) ->
        try
            _.assign @state, JSON.parse str
            @emit "change", @state
        catch e
            console.log e

    commitState: ->
        @emit "change", @state

    clearError: => @state.error = null

    exec: (cmd) ->
        img = this
        try
            res = (eval cmd)

            # if successful, reset the console and set
            # last command
            resetConsole()
            setLastCommand cmd
            @clearError()
            @commitState()
            return res
        catch e
            @state.error = e
            @emit "error", e
            @emit "change"

    invertPixel: (x, y) ->
       @state.rows[x][y] = Math.abs (255- @state.rows[x][y])
       @commitState()

    setPixelxy: (x, y, rgb) ->
        @state.rows[x][y] = rgb
        @commitState()

    map: (cmd, cb) -> 
            img = this
            try
                rows = @state.rows

                _img = (x, y) ->
                    getPixel: -> rows[y][x]
                    setPixel: (rgb) -> rows[y][x] = rgb

                f = new Function("img", cmd)

                for r, y in rows
                    for p, x in r
                        f _img(x, y)
                resetConsole()
                setLastCommand cmd
                @clearError()
                @commitState()
                cb?()
            catch e
                @state.error = e
                @emit "change"
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
        try
            @state.rows[@state.selectedPixel[0]][@state.selectedPixel[1]] = rgb

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
    Reflux: Reflux
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
    LastCommandDisplay: LastCommandDisplay
    Modal: Modal
    modal: modal
    hintize: hintize
