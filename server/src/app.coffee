Q = require 'q'
path = require 'path'
manikin = require 'manikin-mongodb'
rester = require 'rester'
async = require 'async'
nconf = require 'nconf'
_ = require 'underscore'
_.mixin require 'underscore.plus'
express = require 'express'
lockeClient = require 'locke-client'
resterTools = require 'rester-tools'



# Model support
# =============================================================================

defaultAuth = (targetProperty) -> (user) ->
  if user?.id then  _.makeObject(targetProperty || 'user', user.id) else null




# Models
# =============================================================================

models =
  users:
    auth: defaultAuth 'id'
    owners: {}
    fields:
      email: { type: 'string', required: true, unique: true }
      name: { type: 'string', default: '' }

  accounts:
    auth: defaultAuth()
    owners: user: 'users'
    defaultSort: 'name'
    fields:
      name: { type: 'string' }
  
  verifications:
    auth: defaultAuth()
    owners: user: 'users'
    defaultSort: 'date'
    fields:
      name: { type: 'string' }
      comment: { type: 'string' }
      date: { type: 'date' }
  
  transactions:
    auth: defaultAuth()
    owners: verification: 'verifications'
    fields:
      value: { type: 'number' }
      account:
        type: 'hasOne'
        model: 'accounts'
        validation: (transaction, account, callback) ->
          if transaction.user.toString() != account.user.toString()
            callback 'The account does not belong to the same user as the verification'
          callback()
  
  tags:
    auth: defaultAuth()
    owners: account: 'accounts'
    defaultSort: 'name'
    fields:
      name: { type: 'string' }



# Application entry point
# =============================================================================

exports.run = (settings, callback) ->

  # Reading and echoing the configuration for the application
  settings ?= {}
  callback ?= ->

  nconf.env().argv().overrides(settings).defaults
    mongo: 'mongodb://localhost/moneypenny'
    PORT: settings.port || 3003

  console.log "Starting up..."
  console.log "* mongo: " + nconf.get('mongo')
  console.log "* environment: " + process.env.NODE_ENV
  console.log "* port: " + nconf.get('PORT')

  # Creating the interface to the database
  db = manikin.create()

  # Setting up the express app
  app = express.createServer()
  app.use express.bodyParser()
  app.use express.responseTime()
  app.use resterTools.versionMid path.resolve(__dirname, '../package.json')

  # Setting up locke
  sharpLocke = process.env.NODE_ENV == 'production'
  locke = lockeClient(if sharpLocke then 'https://locke.nodejitsu.com' else 'http://localhost:6002') # TODO: must set up https for lockeapp.com so the proper DNS (abstracting underlying provider) can be used

  # Defining where user are stored in the models and how to get them
  userModels = [
    table: 'users'
    usernameProperty: 'email'
    callback: (r) -> { id: r.id }
  ]
  getUserFromDb = resterTools.authUser(
    resterTools.authenticateWithBasicAuthAndLocke(locke, 'moneypenny')
    resterTools.getAuthorizationData(db, userModels)
  )

  # Registering all models
  db.defModels models

  # Connecting to the database
  Q.ninvoke(db, 'connect', nconf.get('mongo'))
  .fail ->
    console.log "ERROR: Could not connect to db"

  #  Adding users to locke if it's being mocked
  .then ->
    return if sharpLocke
    Q.ninvoke(resterTools, 'getAllUsernames', db, userModels)
    .then (usernames) ->
      Q.ninvoke(resterTools, 'createLockeUsers', locke, 'moneypenny', 'summertime', usernames)
    .end()

  # Adding custom routes to the app
  .then ->

    app.get '/auth', (req, res) ->
      getUserFromDb req, (err, status) ->
        if req.headers.origin
          res.header 'Access-Control-Allow-Origin', req.headers.origin
          res.header 'Access-Control-Allow-Credentials', 'true'
          res.header 'Access-Control-Allow-Headers', req.headers['access-control-request-headers'] || 'Authorization' # Maybe these: 'origin, authorization, accept' or req.headers['access-control-allow-headers']
          res.header 'Access-Control-Allow-Methods', 'POST, GET, OPTIONS, DELETE, PUT'
        res.json({ authenticated: status? })

  # Starting up the server
  .then ->
    rester.exec app, db, getUserFromDb, models
    app.listen nconf.get('PORT')
    console.log "Ready!"
    callback()
  .end()
