# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require fabric
#= require ifs_render
#= require jquery-ui/core
#= require jquery-ui/widget
#= require jquery-ui/mouse
#= require jquery-ui/position
#= require jquery-ui/button
#  require jquery-ui
#= require evol.colorpicker

angular.module('ifs',["controllers"])
controllers = angular.module('controllers',[])
controllers.controller("ifs_controller", [ '$scope',
  (scope)->
    scope.depth = 8
    scope.flipX = false
    scope.flipY = false
    scope.transformation = undefined
  ])
jQuery ->
  @ifs_scope = $('[ng-controller=ifs_controller]').scope()

  body=$ 'body'
    
  @c = new fabric.Canvas 'modeling_canvas', {'selection': false, backgroundColor: "yellow", centeredRotation: true, centeredScaling: true}
  
  create_rect= (opts)=>
    if opts
      o={}
      for prop in ifs_properties
        o[prop] = opts[prop] if opts[prop] != undefined
      opts = o

      #opts = o
    opts||={width: 200, height: 200, left: 0, top: 0}
    opts.color||='#000'
    opts.stroke = 'black'
    opts.cornerColor="black"
    opts.borderColor="black"
    rect = new fabric.Rect opts
    rect.setGradient 'fill', {x0: 0, x1: 1, x2:200, y2:200, colorStops: {0: "rgba(10, 20, 30, 0.5)", 1: "white"}}
    @c.add rect

  for rect in JSON.parse $("#iterated_function_system_transforms").val()
    create_rect rect

  
  @c.renderAll()

  #Angular
  @ifs_scope.$watch 'transformation', (tfm, old) =>
    for prop in ['flipX', 'flipY']
      if tfm
        @ifs_scope[prop] = tfm[prop]
      else
        @ifs_scope[prop] = undefined
      console.log @ifs_scope.base_shape

  lost_selected= =>
    @ifs_scope.transformation = undefined
    @ifs_scope.$apply()
  @c.on 'selection:cleared', lost_selected
  @c.on 'object:removed', lost_selected
    
  @c.on 'object:selected', (e)=>
    @ifs_scope.transformation = @c.getActiveObject()
    @ifs_scope.$apply()
    rect = e.target
    #$('#flip_x').prop 'checked', rect.getFlipX()
    $('#flip_y').prop 'checked', rect.getFlipY()
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

  @c.on "object:modified", =>
    @ifs_eng.render (@c.getObjects())

  @c.on "object:scaling", =>
    @ifs_eng.render (@c.getObjects())

  @c.on "object:rotating", =>
    @ifs_eng.render (@c.getObjects())

  @c.on "object:moving", =>
    @ifs_eng.render (@c.getObjects())

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


  
