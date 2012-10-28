window.ctrlAccounts = ($scope, $http) ->

  baseScope $http, $scope

  getAuthorized($http, "/operators").success (ops) ->
    getAuthorized($http, '/assignments').success (ass) ->
      getAuthorized($http, '/criterions').success (crit) ->

        # haxx
        ops.forEach (op) ->
          op.assignments = ass.filter((x) -> x.operator == op.id)
          op.assignments.forEach (as) ->
            as.criterions = crit.filter((x) -> x.assignment == as.id)



        ops.forEach (op) ->
          op.lastLogin = op.lastLogged
          op.created = op.creationDate
    
        $scope.operators = ops

        $scope.operators.forEach (op) ->
          op.assignmentsCount = op.assignments.length
          op.assignmentsPassed = op.assignments.filter((x) -> x.criterions.every((s) -> s.passed)).length

        $scope.operators.forEach (op) ->
          op.passedAll = op.assignmentsCount == op.assignmentsPassed

        $scope.operators.forEach (op) ->
         op.progress = Math.round(op.assignmentsPassed * 100.0 / op.assignmentsCount)
