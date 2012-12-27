module = angular.module('moneypenny', [])
backend = require('lib/backend').connect(module, lockeClient)

window.auth = backend.auth
window.login = backend.login
window.isAuthenticated = backend.isAuthenticated



## Setting the base scope, used on all pages
## =========================================
window.baseScope = ($http, $scope) ->

  $scope.menu = [
    name: 'Konton'
    url: '#/accounts'
  ,
    name: 'Verifikationer'
    url: '#/verifications'
  ,
    name: 'Taggar'
    url: '#/tags'
  ,
    name: 'Statistik'
    url: '#/stats'
  ]

  $scope.menu.forEach (menu) ->
    if menu.url == window.location.hash
      menu.active = "active"

  $scope.logout = ->
    backend.logout()



module.directive 'chosen', ->
  restrict: 'A'
  link: (scope, element, attr) ->
    scope.$watch attr.chosenSource, ->
      element.trigger 'liszt:updated'
    element.chosen()
  


## Application routing for all the controllers and views
## =====================================================
module.config ($routeProvider) ->
  $routeProvider
  .when '/login'
    templateUrl: '/views/login.html'
    controller: ctrlLogin
  .when '/accounts'
    templateUrl: '/views/accounts.html'
    controller: ctrlAccounts
  .when '/verifications'
    templateUrl: '/views/verifications.html'
    controller: ctrlVerifications
  .when '/new-verification'
    templateUrl: '/views/verification.html'
    controller: ctrlNewVerification
  .when '/stats'
    templateUrl: '/views/stats.html'
    controller: ctrlStats
  .when '/tags'
    templateUrl: '/views/tags.html'
    controller: ctrlTags
  .when '/accounts/:account'
    templateUrl: '/views/account.html'
    controller: ctrlAccount
  .when '/verifications/:verification'
    templateUrl: '/views/verification.html'
    controller: ctrlVerification
  .otherwise
    redirectTo: '/login'



## Minor hack for applying jQuery plugins on certain elements
## ==========================================================
setInterval ->
  #$('select').chosen()
  $('a[rel="popover"]').popover()
  $('a[rel="tooltip"]').tooltip()
, 100
