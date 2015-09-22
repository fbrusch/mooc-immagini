React = require 'react'

module.exports = ConsoleDisplay = React.createClass
    render: ->
        {div, p} = React.DOM
        div null,
            @props.lines.map (x, i) ->
                p {key: i}, x
