window.ctrlVerifications = ($scope, $http) ->

  baseScope $http, $scope

  auth.get($http, "/verifications").success (verifications) ->
    $scope.verifications = verifications

  $scope.deleteVerification = (verification) ->
    smoke.confirm 'Är du säker på att du vill ta bort "' + verification.name + '"?', (confirmed) ->
      return if !confirmed
      auth.del($http, "/verifications/#{verification.id}").success ->
        $scope.verifications = $scope.verifications.filter (x) -> x.id != verification.id
