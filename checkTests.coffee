module.exports = (tests) ->
    tests.map (x) -> x.test()
        .reduce (a, b) -> a and b
