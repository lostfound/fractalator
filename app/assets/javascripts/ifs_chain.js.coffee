# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require fabric
#= require ngDraggable
#= require ifs_chain_render
#= require jquery-ui/core
#= require jquery-ui/widget
#= require jquery-ui/mouse
#= require jquery-ui/position
#= require jquery-ui/button
#  require jquery-ui
#= require evol.colorpicker
#= require intense

ifs =angular.module('ifs',["controllers", 'ngDraggable'])
ifs.directive 'convertToNumber', ->
  require: 'ngModel'
  link: (scope, element, attrs, ngModel)->
    console.log element
    ngModel.$parsers.push (val)->
      parseInt val
    ngModel.$formatters.push (val)->
      '' + val
controllers = angular.module('controllers',[])
controllers.controller("ifs_chain_controller", [ '$scope',
  ($scope)->
    s=$scope
    s.to_int= (num)->
      parseInt num
    s.base_shape = 0
    s.depth ||= 8
    s.flipX = false
    s.flipY = false
    s.extra_opts = false
    s.angle = 0
    s.apply = true
    s.width = 0
    s.height= 0
    s.top   = 0
    s.left  = 0
      
    s.transformation = undefined
    ppl = $("[data-pipeline]").data 'pipeline'
    if ppl
      s.pipeline = ppl
    s.pipeline ||= []
    s.chain_length= ->
      ppl = ( fr for fr in s.pipeline when fr.repeats and fr.repeats > 0 )
      sum = 0
      for fr in ppl
        sum += fr.repeats
      "#{s.depth}%#{sum} = #{s.depth%sum}"
      

    s.ch_fractal= (index)->
      s.changed_fractal = index
      s.show_fractal_selector = true

    s.rm_fractal= (index)->
      if s.pipeline.length > 1
        s.pipeline.splice index, 1
        s.on_change_pipeline()
    s.close_selector= ->
      s.show_fractal_selector=false

    s.add_fractal= ->
      s.show_fractal_selector=true

    s.select_fractal= (fractal)->
      if s.changed_fractal != undefined
        s.pipeline[s.changed_fractal] = fractal
      else
        s.pipeline.push fractal
      fractal.repeats = 1
      s.on_change_pipeline()
      s.show_fractal_selector=false
      try
        s.$apply()
      catch
    s.selector_url = $('#fractal_selector').data 'path'
    $('body').off 'change', '#fractal_pipeline input.repeats'
    $('body').on  'change', '#fractal_pipeline input.repeats', ->
      s.on_change_pipeline()

    $('body').off 'click', '#available_fractals img[data-url]'
    $('body').on  'click', '#available_fractals img[data-url]', ->
      $.get $(@).data('url'), null, (data)->
        s.select_fractal data
      , 'JSON'
    $('body').off 'click', '#available_fractals a'
    $('body').on  'click', '#available_fractals a', ->
      s.selector_url = $(@).attr 'href'
      $.get s.selector_url, null, (data)->
        $('#available_fractals').replaceWith data
      false
    # watch
    s.$watch 'base_shape', (v)->
      s.on_change_pipeline()
    # watch
    s.$watch 'show_fractal_selector', (v)->
      return s.changed_fractal = undefined unless v
      $.get s.selector_url, null, (data)->
        $('#available_fractals').replaceWith data
    if s.pipeline.length == 0
      s.show_fractal_selector = true
    s.on_drop= (index, index2, evt)->
      obj = s.pipeline[index]
      s.pipeline[index]  = s.pipeline[index2]
      s.pipeline[index2] = obj
      s.on_change_pipeline()

    s.$watch 'depth', ->
      s.on_change_pipeline()
    
    #ifs_eng.render (@c.getObjects())
    ifs_eng = undefined
    s.on_change_pipeline= ->
      unless ifs_eng
        ifs_eng = new IfsChainRender scope: s, dest_input: '#ifs_chain_image'
      ifs_eng.render s.pipeline, true

    #$('body').addClass 'body_blocked'

    #SUBMIT
    $('body').off 'click', '#submit_form'
    $('body').on 'click', '#submit_form', =>
      return false if s.pipeline.length <= 1
      $("#ifs_chain_pipeline").val JSON.stringify s.pipeline
      console.log $("#ifs_chain_pipeline").val()

      $("#ifs_form").submit()
  ])
