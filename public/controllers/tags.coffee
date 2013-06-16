window.ctrlTags = ($scope, $http) ->

  baseScope $http, $scope

  auth.get($http, "/tags").success (tags) ->
    $scope.tags = tags

  $scope.createTag = ->
    smoke.prompt 'Namn på den nya taggen', (name) ->
      return if !name
      auth.post($http, '/tags', { name: name }).success (tag) ->
        $scope.tags.push tag

  $scope.updateTag = (tag) ->
    auth.put($http, "/tags/#{tag.id}", { name: tag.name })

  $scope.deleteTag = (tag) ->
    smoke.confirm 'Är du säker på att du vill ta bort "' + tag.name + '"?', (confirmed) ->
      return if !confirmed
      auth.del($http, "/tags/#{tag.id}").success ->
        $scope.tags = $scope.tags.filter (x) -> x.id != tag.id
