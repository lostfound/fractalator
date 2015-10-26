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

ifs =angular.module('ifs',["controllers", 'ngRoute', 'ngDraggable', 'ngTurbolinks'])
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
_sa= ->
  body=$ 'body'
  @ifs_scope = $('[ng-controller=ifs_controller]').scope()
    
  @c = new fabric.Canvas 'modeling_canvas', {'selection': false, backgroundColor: "yellow", centeredRotation: true, centeredScaling: true}
  
  create_rect= (opts)=>
    if opts
      o={}
      for prop in ifs_properties
        o[prop] = opts[prop] if opts[prop] != undefined
      opts = o

      #opts = o
    opts||={width: 200, height: 200, left: 0, top: 0}
    opts.originX ||= 'center'
    opts.originY ||= 'center'
    opts.left||=100
    opts.top||=100
    opts.color||='#000'
    opts.stroke = 'black'
    opts.cornerColor="black"
    opts.borderColor="black"
    rect = new fabric.Rect opts
    rect.setGradient 'fill', {x0: 0, x1: 1, x2:200, y2:200, colorStops: {0: "rgba(10, 20, 30, 0.5)", 1: "white"}, originY: 'center', originX: 'center'}
    @c.add rect

  for rect in JSON.parse $("#iterated_function_system_transforms").val()
    create_rect rect

  
  @c.renderAll()

  #Angular
  get_geometry= (tfm)->
    if tfm
      @ifs_scope.angle = parseInt tfm.angle%360
      @ifs_scope.width = parseInt(tfm.scaleX*tfm.width)
      @ifs_scope.height= parseInt(tfm.scaleY*tfm.height)
      @ifs_scope.left  = tfm.left
      @ifs_scope.top   = tfm.top

  @ifs_scope.$watch 'transformation', (tfm, old) =>
    for prop in ['flipX', 'flipY']
      if tfm
        @ifs_scope[prop] = tfm[prop]
      else
        @ifs_scope[prop] = undefined
    get_geometry tfm

  lost_selected= =>
    @ifs_scope.transformation = undefined
    @ifs_scope.$apply()
  @c.on 'selection:cleared', lost_selected
  @c.on 'object:removed', lost_selected
    
  @c.on 'object:selected', (e)=>
    @ifs_scope.apply = false
    @ifs_scope.transformation = @c.getActiveObject()
    @ifs_scope.$apply()
    @ifs_scope.apply = true
    @ifs_scope.$apply()
    rect = e.target
    # Color picker
    $("#color").colorpicker "val", rect.color

  # Recursions
  @ifs_scope.$watch 'depth', (depth, old_value)=>
    @ifs_eng.render @c.getObjects(), true

  #Shapes
  @ifs_scope.$watch 'base_shape', (nv,ov)=>
    @ifs_eng.render @c.getObjects(), true

  # Flips
  @ifs_scope.$watch 'flipX', (value, old) =>
    if @ifs_scope.transformation and @ifs_scope.transformation.flipX != value
      @ifs_scope.transformation.set {flipX: value}
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'flipY', (value, old) =>
    if @ifs_scope.transformation and @ifs_scope.transformation.flipY != value
      @ifs_scope.transformation.set {flipY: value}
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'width', (value, old) =>
    if @ifs_scope.apply and tfm = @ifs_scope.transformation
      tfm.set {scaleX: @ifs_scope.width/tfm.width}
      @c.renderAll()
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'height', (value, old) =>
    if @ifs_scope.apply and tfm = @ifs_scope.transformation
      tfm.set {scaleY: @ifs_scope.height/tfm.height}
      @c.renderAll()
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'top', (value, old) =>
    if @ifs_scope.apply and tfm = @ifs_scope.transformation
      tfm.set {top: @ifs_scope.top}
      @c.renderAll()
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'left', (value, old) =>
    if @ifs_scope.apply and tfm = @ifs_scope.transformation
      tfm.set {left: @ifs_scope.left}
      @c.renderAll()
      @ifs_eng.render (@c.getObjects())

  @ifs_scope.$watch 'angle', (value, old) =>
    if @ifs_scope.apply and tfm = @ifs_scope.transformation
      tfm.set {originX: 'center', originY: 'center'}
      tfm.rotate value
      @c.renderAll()
      @ifs_eng.render (@c.getObjects())


  transf_changed= ->
    @ifs_scope.apply = false
    get_geometry @ifs_scope.transformation
    @ifs_scope.$apply()
    @ifs_eng.render (@c.getObjects())
  @c.on "object:modified", =>
    transf_changed()
    @ifs_scope.apply = true
    @ifs_scope.$apply()

  @c.on "object:scaling", =>
    transf_changed()

  @c.on "object:rotating", =>
    transf_changed()

  @c.on "object:moving", =>
    transf_changed()

  body.off 'click', "#rect_up"
  body.off 'click', "#rect_down"
  body.off 'click', "#rect_add"
  body.off 'click', "#rect_del"

  # UP
  body.on 'click', "#rect_up", =>
    if rect = @c.getActiveObject()
      @c.bringForward(rect)
      @ifs_eng.render (@c.getObjects())
    false

  # DOWN
  body.on 'click', "#rect_down", =>
    if rect = @c.getActiveObject()
      @c.sendBackwards(rect)
      @ifs_eng.render (@c.getObjects())
    false

  # ADD
  body.on 'click', "#rect_add", =>
    create_rect(@c.getActiveObject())
    @ifs_eng.render (@c.getObjects())

  # DEL
  body.on 'click', "#rect_del", =>
    rect = @c.getActiveObject()
    if rect
      rect.remove()
      @ifs_eng.render (@c.getObjects())

  # Color picker
  $("#color").colorpicker()# {parts: 'full', alpha: true, showOn: 'both', buttonColorize: true, showNoneButton: true}
  body.off "change", "#color"
  body.on  "change.color", "#color", =>
    if rect = @c.getActiveObject()
      rect.color = $("#color").val()
      @ifs_eng.render @c.getObjects(), true

  #SUBMIT
  body.off 'click', '#submit_form'
  body.on 'click', '#submit_form', =>
    transforms = []
    for rect in @c.getObjects()
      hash = {}
      for prop in ifs_properties
        hash[prop] = rect[prop]
      transforms.push hash
     $("#iterated_function_system_transforms").val JSON.stringify transforms
     $("#ifs_form").submit()

  @ifs_eng = new IfsRenderer
  @ifs_eng.render (@c.getObjects())


  
