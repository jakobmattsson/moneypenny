window.ctrlLogin = ($scope, $http) ->

  $scope.username = ''
  $scope.password = ''

  $scope.login = ->
    login $http, $scope.username, $scope.password, (err) ->
      return alert(err) if err
      alert("ok!")
      window.location = "#/operators"
    false
