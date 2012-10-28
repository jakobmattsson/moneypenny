window.ctrlNewVerification = ($scope, $routeParams, $http) ->

  baseScope $http, $scope

  auth.get($http, "/accounts").success (accounts) ->
    $scope.accounts = accounts
