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
jQuery ->
  body=$ 'body'
  properties = ['width', 'height', 'left', 'top', 'scaleX', 'scaleY', 'angle', 'flipX', 'flipY', 'x', 'y', 'color']
  @c = new fabric.Canvas 'modeling_canvas', {'selection': false, backgroundColor: "yellow", centeredRotation: true, centeredScaling: true}
  
  create_rect= (opts)=>
    if opts
      o={}
      for prop in properties
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
  # Flips
  body.off 'change', '#flip_x'
  body.off 'change', '#flip_y'
  body.on 'change', '#flip_x', =>
    rect = @c.getActiveObject()
    if rect
      rect.set { flipX: $('#flip_x').prop 'checked' }
      @ifs_eng.render (@c.getObjects())

  @c.on 'object:selected', (e)=>
    rect = e.target
    $('#flip_x').prop 'checked', rect.getFlipX()
    $('#flip_y').prop 'checked', rect.getFlipY()
    # Color picker
    $("#color").colorpicker "val", rect.color
    $("#opts_for_selected").show()


  body.on 'change', '#flip_y', =>
    rect = @c.getActiveObject()
    if rect
      rect.set { flipY: $('#flip_y').prop 'checked' }
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
      for prop in properties
        hash[prop] = rect[prop]
      transforms.push hash
     $("#iterated_function_system_transforms").val JSON.stringify transforms
     $("#ifs_form").submit()

  # RECURSIONS
  body.off 'keyup', '#iterated_function_system_rec_number'
  body.on 'keyup', '#iterated_function_system_rec_number', =>
    @ifs_eng.render @c.getObjects(), true
  body.off 'change', '#iterated_function_system_rec_number'
  body.on 'change', '#iterated_function_system_rec_number', =>
    @ifs_eng.render @c.getObjects(), true
  body.off 'change', '#iterated_function_system_base_shape'
  body.on  'change', '#iterated_function_system_base_shape', =>
    @ifs_eng.render @c.getObjects(), true

  @c.on "object:modified", =>
    @ifs_eng.render (@c.getObjects())
  @c.on "object:scaling", =>
    @ifs_eng.render (@c.getObjects())
  @c.on "object:rotating", =>
    @ifs_eng.render (@c.getObjects())
  @c.on "object:moving", =>
    @ifs_eng.render (@c.getObjects())

  @ifs_eng = new IfsRenderer
  @ifs_eng.render (@c.getObjects())
  
