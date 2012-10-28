authMod = require('lib/interceptUnauthorized')
store = require('store')
backend = 'http://localhost:3003'

exports.connect = (module, lockeClient) ->

  ## Basic auth helper
  ## =================
  makeBaseAuth = (user, pass) -> 'Basic ' + btoa(user + ':' + pass)



  ## Setting up a locke-connection to the edvirt-application
  ## =======================================================
  lockeBaseUrl = if window.location.hostname == 'localapi.localhost' then 'http://localhost:6002' else 'https://locke.nodejitsu.com'
  locke = lockeClient.connectAppWithJQuery 'moneypenny', lockeBaseUrl, jQuery


  ## Intercept unauthorized requests
  ## ===============================
  authMod.interceptUnauthorized
    module: module
    transformRequest: (config) ->
      config.headers ?= {}
      config.headers.Authorization = makeBaseAuth(store.get('auth')?.username, store.get('auth')?.password)
      config
    requireLogin: (http, callback) ->
      prompt = (msg) ->
        msg = msg || (if store.get('auth') then 'Invalid username or password' else 'Must login to access this page')
        smoke.prompt msg, (input) ->
          if !input # user aborted. go to main login page.
            callback(false)
            window.location = '#/login' 
            return

          username = input.split(' ')[0]
          password = input.split(' ')[1]

          login http, username, password, (err) ->
            return prompt(err) if err
            callback(true)

      prompt()



  ## Public API
  ## ==========
  getAuthorized: ($http, path) ->
    $http
      method: 'GET'
      url: backend + path
      headers:
        Authorization: makeBaseAuth(store.get('auth')?.username, store.get('auth')?.password)

  logout: -> store.remove('auth')

  login: (http, username, password, callback) ->
    return callback('Enter username and password') if !username || !password

    locke.authPassword username, password, 86400, (err, data) ->
      return callback(err.toString()) if data.err

      if data.status != 'OK'
        if data?.status?.match /^There is no/
          callback('No such user')
        else
          callback(data.status)
        return

      config = headers:
        Authorization: makeBaseAuth(username, data.token)

      http.get(backend + '/auth', config).success (res) ->
        return callback('Unauthenticated') if !res.authenticated

        store.set "auth", {
          username: username
          password: data.token
        }
        callback()
