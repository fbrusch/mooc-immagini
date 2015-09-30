
channel = undefined

outcome = false

window.getState =  -> JSON.stringify {} 
window.getGrade = -> JSON.stringify outcome
window.setState = -> {} 

if window.parent isnt window
    channel = window.channel = Channel.build
        window: window.parent
        origin: "*"
        scope: "JSInput"

    channel.bind "getGrade",  -> window.getGrade.apply null, arguments
    channel.bind "getState",  -> window.getState.apply null, arguments
    channel.bind "setState",  -> window.setState.apply null, arguments
