window.ctrlAccount = ($scope, $routeParams, $http) ->

  baseScope $http, $scope

  auth.get($http, "/accounts/#{$routeParams.account}").success (account) ->
    $scope.account = account
