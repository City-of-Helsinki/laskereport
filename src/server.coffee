express = require 'express'
path = require 'path'
config = require 'config'

STATIC_URL = config.get 'static_url'

staticFile = (fpath) ->
    STATIC_URL + '/' + fpath

exports.createServer = ->
    app = express()
    app.set 'views', path.join(__dirname, './')
    app.set 'view engine', 'jade'
    app.use STATIC_URL, express.static './dist'

    server = app.listen config.get 'express_port'

    app.get '/', (req, res, next) ->
        console.log "GET #{req.path}"
        res.render 'index.jade',
            pretty: true
            staticFile: staticFile
            configJson: JSON.stringify config
