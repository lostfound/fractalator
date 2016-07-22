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
#= require foundation
#= require turbolinks
#= require angular
#= require jquery_ujs
#= require vendor/modernizr
#= require jquery-hotkeys
#
#= require ngDraggable
#= require ng
#= require ifs_likes
#= require fabric
#
#= require jquery-ui/core
#= require jquery-ui/widget
#= require jquery-ui/mouse
#= require jquery-ui/position
#= require jquery-ui/button
#= require evol.colorpicker
#= require intense
#
#= require ifs_render
#= require ifs_animation
#= require ifs_chain_render
#= require ifs_chain_animation
#= require iterated_function_systems
#= require ifs_chain

scroll_pos=null
$(document).on 'turbolinks:render', ->
  if scroll_pos
    $(document).scrollTop scroll_pos
    scroll_pos = null

$("html").on 'click', '.keepscroll', ->
  scroll_pos = $(document).scrollTop()
  true
$(document).foundation()
window.modules = {}
