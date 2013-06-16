window.ctrlAccount = ($scope, $routeParams, $http) ->

  baseScope $http, $scope

  auth.get($http, "/accounts/#{$routeParams.account}").success (account) ->
    $scope.account = account

  auth.get($http, "/accounts/#{$routeParams.account}/accountTags").success (accountTags) ->
    $scope.accountTags = accountTags
    $scope.accountTagIds = accountTags.map (x) -> x.id
    console.log accountTags

  auth.get($http, "/tags").success (tags) ->
    $scope.tags = tags

  window.print = ->
    console.log $scope

  $scope.selFun = (tag) ->
    v = _($scope.accountTagIds.map((x) -> x.id)).contains(tag.id)
    console.log v
    v

  $scope.updateAccountTags = ->
    $scope.accountTags.forEach (a) ->
      auth.post($http, "/accounts/#{$routeParams.account}/accountTags/#{a.id}").success () ->
        console.log "d"


    # console.log "uppd", $scope

  # auth.post($http, "/accounts/#{$routeParams.account}/tags", { name: 'now' }).success (tags) ->
  #   console.log "hej", tags

