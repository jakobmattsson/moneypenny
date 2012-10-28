module = angular.module('moneypenny', [])
backend = require('lib/backend').connect(module, lockeClient)

window.getAuthorized = backend.getAuthorized
window.login = backend.login



## Setting the base scope, used on all pages
## =========================================
window.baseScope = ($http, $scope) ->
  $scope.logout = ->
    backend.logout()



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
  .otherwise
    redirectTo: '/login'



## Minor hack for applying jQuery plugins on certain elements
## ==========================================================
setInterval ->
  $('select').chosen()
  $('a[rel="popover"]').popover()
  $('a[rel="tooltip"]').tooltip()
, 100
