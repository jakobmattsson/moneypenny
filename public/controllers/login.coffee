window.ctrlLogin = ($scope, $http) ->
  window.location = '#/accounts' if isAuthenticated()

  $scope.username = ''
  $scope.password = ''

  $scope.login = ->
    login $http, $scope.username, $scope.password, (err) ->
      return alert(err) if err
      window.location = "#/accounts"
    false
