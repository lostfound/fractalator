window.ifs =angular.module('ifs',["controllers", 'ngDraggable'])
window.controllers = angular.module('controllers',[])

controllers.controller("custom_fractal", [ '$scope',
  (scope)->
  ])
ifs.directive 'convertToNumber', ->
  require: 'ngModel'
  link: (scope, element, attrs, ngModel)->
    console.log element
    ngModel.$parsers.push (val)->
      parseInt val
    ngModel.$formatters.push (val)->
      '' + val

$(document).on "turbolinks:load", ->
  angular.bootstrap(document.body, ['ifs'])

$(document).on "turbolinks:before-visit", ->
  for ngc in $("[ng-controller]")
    $(ngc).scope().$broadcast("$destroy")
