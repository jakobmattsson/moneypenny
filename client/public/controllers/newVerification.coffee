window.ctrlNewVerification = ($scope, $http, $q) ->

  baseScope $http, $scope

  addTransaction = do ->
    transactionCounter = 0
    -> $scope.transactions.push({ id: transactionCounter++ })

  auth.get($http, "/accounts").success (accounts) ->
    $scope.accounts = accounts
    $scope.transactions = []
    $scope.addTransaction = addTransaction
    addTransaction()

  $scope.title = 'Ny verifikation'
  $scope.date = new XDate().toString('yyyy-MM-dd')

  $scope.deleteTransaction = (transaction) ->
    $scope.transactions = $scope.transactions.filter (x) -> x.id != transaction.id

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

    auth.post($http, '/verifications', { date: $scope.date, name: $scope.name, comment: $scope.comment }).success (newVerification) ->
      $q.all $scope.transactions.map (transaction) ->
        auth.post $http, "/verifications/#{newVerification.id}/transactions",
          value: transaction.value
          account: transaction.account.id
      .then (data) ->
        window.location = '#/verifications'
