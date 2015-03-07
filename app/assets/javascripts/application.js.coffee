# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery2
#= require jquery.turbolinks
#= require turbolinks
#= require angular
#= require angular-route
#= require angular-turbolinks
#= require jquery_ujs
#= require vendor/modernizr
#= require foundation
#= require jquery-hotkeys

jQuery ->
  $(document).foundation()
  if $("#main_section").height() < $(window).height()
    $("footer").hide()
  window.modules = {}
  #$('[ng-app]').each ->
  #  module = $(@).attr('ng-app')
  #  console.log angular.bootstrap(@, [module])
  #window.frapp = angular.module "fractalator", []
  ## See https://docs.angularjs.org/guide/bootstrap
  ## http://stackoverflow.com/questions/14797935/using-angularjs-with-turbolinks#answer-15488920
  #angular.bootstrap document, ["fractalator"]
  #
