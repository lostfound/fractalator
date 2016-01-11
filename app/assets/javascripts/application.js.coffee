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
#= require foundation
#= require turbolinks
#= require angular
#  require angular-route
#  require angular-turbolinks
#= require jquery_ujs
#= require vendor/modernizr
#= require jquery-hotkeys

console.log "!"
$(document).foundation()
scroll_pos=null
$(document).on 'page:load', ->
  if scroll_pos
    $(document).scrollTop scroll_pos
    scroll_pos = null

$(document).on "page:load ready", ->
  if $("[ng-controller]").length > 0
    angular.bootstrap(document.body, ['ifs'])

$(document).on "page:before-change", ->
  for ngc in $("[ng-controller]")
    $(ngc).scope().$broadcast("$destroy")

jQuery ->
  $("body").off 'click', '.keepscroll'
  $("body").on 'click', '.keepscroll', ->
    scroll_pos = $(document).scrollTop()
    true
  $(document).foundation()
  #if $("#main_section").height() + $("header").height() < $(window).height()
  #  $("footer").hide()
  window.modules = {}
