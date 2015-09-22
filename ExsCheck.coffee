React = require 'react'
FontAwesome = require 'react-fontawesome'

_e = React.createElement

ok = React.createClass 
    render: -> 
        React.createElement FontAwesome,
            name: "check", 
            style: {color:"green"}

ko = React.createClass
    render: ->
        React.createElement FontAwesome,
            name: "check"
            style: {color:"red"}

#module.exports = ExsCheck = React.createClass 
    #render: ->
        #{span, p, div, i} = React.DOM
        #div null, 
            #@props.tests.map (x) ->
                #div null,
                    #(span null, x.display) 
                    #if x.test() 
                        #React.createElement ok 
                    #else 
                        #React.createElement ko
module.exports = ExsCheck = React.createClass 
                render: ->
                    {span, p, div, i} = React.DOM
                    div null, 
                        @props.tests.map (x) ->
                            res = x.test()
                            div null,
                                (span null, if res then x.success else x.display) 
                                if res then (_e ok) else (_e ko)
