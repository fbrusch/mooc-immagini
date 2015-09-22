FROM node
RUN npm install -g livereload
VOLUME /watch_dir
CMD livereload /watch_dir

