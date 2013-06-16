oneAtATime = (f) ->
  running = false
  (params..., cb) ->
    return if running
    running = true
    f.apply this, params.concat [->
      running = false
      cb.apply this, arguments
    ]

exports.interceptUnauthorized = (params) ->
  params ?= {}
  params.requireLogin ?= ->
  params.filter ?= -> true
  params.transformRequest ?= (x) -> x

  http = null
  unauthedRequest = []
  loginReq = oneAtATime(params.requireLogin)

  params.module.config ($httpProvider) ->
    $httpProvider.responseInterceptors.push ($q) ->
      (promise) ->
        promise.then angular.identity, (response) ->
          if response.status == 401 && params.filter(response.config)
            deferred = $q.defer()
            unauthedRequest.push
              config: response.config
              deferred: deferred
            loginReq http, (shouldRetry) ->
              if shouldRetry
                unauthedRequest.forEach (req) ->
                  http(params.transformRequest(req.config)).then (response) ->
                    req.deferred.resolve(response)
              unauthedRequest = []
            deferred.promise
          else
            $q.reject response

  .run ($http) ->
    http = $http
