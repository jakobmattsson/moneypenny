window.ctrlAccounts = ($scope, $http) ->

  baseScope $http, $scope

  auth.get($http, "/accounts").success (accounts) ->
    $scope.accounts = accounts

  $scope.createAccount = ->
    smoke.prompt 'Namn på det nya kontot', (name) ->
      return if !name
      auth.post($http, '/accounts', { name: name }).success (account) ->
        $scope.accounts.push account

  $scope.deleteAccount = (account) ->
    smoke.confirm 'Är du säker på att du vill ta bort "' + account.name + '"?', (confirmed) ->
      return if !confirmed
      auth.del($http, "/accounts/#{account.id}").success ->
        $scope.accounts = $scope.accounts.filter (x) -> x.id != account.id
