# app-template
Template for html app with nodemon, livereload, browserify, coffee

Usage: 

    git checkout -b master
    mkdir dist
    npm install
    make livereload &
    make watch &
    make open
  
Edit index.jade and app.coffee, and you're good to go!

If you want to change something in the template: 
    
    git checkout template

    [your modifications]

    [git add + commit]

    git checkout master
    git rebase template

