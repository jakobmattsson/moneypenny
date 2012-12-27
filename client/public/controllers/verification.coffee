window.ctrlVerification = ($scope, $http, $routeParams, $q) ->

  baseScope $http, $scope

  auth.get($http, "/accounts").success (accounts) ->
    $scope.accounts = accounts
    accountGroups = _(accounts).groupBy('id')

    auth.get($http, "/verifications/#{$routeParams.verification}/transactions").success (transactions) ->
      $scope.transactions = transactions
      $scope.transactions.forEach (transaction) ->
        transaction.account = accountGroups[transaction.account]?[0]

  auth.get($http, "/verifications/#{$routeParams.verification}").success (verification) ->
    $scope.name = verification.name
    $scope.comment = verification.comment
    $scope.date = new XDate(verification.date).toString('yyyy-MM-dd')

  $scope.title = 'Verifikation'

  $scope.deleteTransaction = (transaction) ->
    smoke.confirm 'Säker på att du vill ta bort transaktionen?', (confirmed) ->
      return if !confirmed
      auth.del($http, "/transactions/#{transaction.id}").success (transaction) ->
        $scope.transactions = $scope.transactions.filter (x) -> x.id != transaction.id

  $scope.addTransaction = ->
    auth.post($http, "/verifications/#{$routeParams.verification}/transactions", { }).success (transaction) ->
      $scope.transactions.push transaction

  $scope.createVerification = ->

    if !$scope.name?.trim()
      alert("Verifikationen måste ha ett namn")
      return

    if $scope.transactions.length == 0
      alert("Lägg till åtminstone en transaktion")
      return

    if $scope.transactions.some((transaction) -> !transaction.account?)
      alert("Välj ett konto för alla transaktioner")
      return

    auth.put($http, "/verifications/#{$routeParams.verification}", { name: $scope.name, comment: $scope.comment }).success ->
      $q.all $scope.transactions.map (transaction) ->
        auth.put $http, "/transactions/#{transaction.id}",
          value: transaction.value
          account: transaction.account.id
