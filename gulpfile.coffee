gulp = require 'gulp'
path = require 'path'
plumber = require 'gulp-plumber'
$ = require('gulp-load-plugins')()
gutil = require 'gulp-util'
cjsx = require 'gulp-cjsx'
bower = require 'gulp-bower'
bowerRequireJS = require 'bower-requirejs'
browserSync = require('browser-sync').create()

server = require './src/server'


gulp.task 'cjsx', ->
    gulp.src('./src/*.cjsx')
        .pipe(plumber())
        .pipe(cjsx({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./dist/scripts/'));

gulp.task 'coffee', ->
    gulp.src('src/scripts/app.coffee', read: false).pipe($.plumber())
      .pipe($.browserify(
        debug: true
        insertGlobals: false
        transform: ['coffeeify']
        extensions: ['.coffee'])).pipe gulp.dest('dist/scripts/')

gulp.task 'bower', ->
    options =
        baseUrl: 'dist',
        config: 'dist/require.config.js',
        transitive: true
    bowerRequireJS options

    #bower().pipe gulp.dest('dist/')

#gulp.task 'templates', ->
#    gulp.src('src/*.jade').pipe($.plumber()).pipe($.jade(pretty: true)).pipe gulp.dest('dist/')

gulp.task 'client-templates', ->
    wrap_begin = (file) ->
        fname = path.basename file.path, '.js'
        return "this[\"JadeJST\"][\"#{fname}\"] = "
    wrap_end = ";\n"

    gulp.src('src/templates/*.jade').pipe($.jade({client: true}))
        .pipe($.insert.wrap(wrap_begin, wrap_end))
        .pipe($.concat('templates.js'))
        .pipe(gulp.dest('./dist'))
        .pipe($.insert.prepend("this[\"JadeJST\"] = {};"))

gulp.task 'vendor', ->
    gulp.src('vendor/stylesheets/**/*').pipe(gulp.dest('./dist/stylesheets/'))


gulp.task 'browser-sync', ->
    #browserSync.init server: false, open: false

gulp.task 'watch', ->
    gulp.watch 'src/*.cjsx', ['cjsx']
    gulp.watch 'src/scripts/*.coffee', ['coffee']
    gulp.watch 'vendor/**/*', ['vendor']
    gulp.watch 'bower.json', ['bower']

gulp.task 'default', [
    'coffee'
    'cjsx'
    'bower'
    'client-templates'
    'browser-sync'
    'vendor'
]

gulp.task 'serve', ['watch', 'default'], ->
    server.createServer()
