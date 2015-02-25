# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#=require fabric
jQuery ->
  body=$ 'body'
  properties = ['width', 'height', 'left', 'top', 'scaleX', 'scaleY', 'angle', 'flipX', 'flipY']
  @c = new fabric.Canvas 'modeling_canvas', {'selection': false, backgroundColor: "yellow", centeredRotation: true, centeredScaling: true}
  @z = new fabric.Canvas 'blackbird_fly', {centeredRotation: true, centeredScaling: true}

  @c.on 'object:selected', (e)=>
    rect = e.target
    $('#flip_x').prop 'checked', rect.getFlipX()
    $('#flip_y').prop 'checked', rect.getFlipY()
    $("#opts_for_selected").show()

  body.off 'change', '#flip_x'
  body.off 'change', '#flip_y'
  body.on 'change', '#flip_x', =>
    console.log "!"
    rect = @c.getActiveObject()
    if rect
      console.log $('#flip_x').prop 'checked'
      rect.set { flipX: $('#flip_x').prop 'checked' }
  body.on 'change', '#flip_y', =>
    rect = @c.getActiveObject()
    if rect
      rect.set { flipY: $('#flip_y').prop 'checked' }
  
  
  create_rect= (opts)=>
    if opts
      o={}
      for prop in properties
        o[prop] = opts[prop] if opts[prop] != undefined
      opts = o

      #opts = o
    opts||={width: 200, height: 200, left: 0, top: 0}
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
  body.on 'click', "#rect_up", =>
    rect = @c.getActiveObject()
    if rect
      @c.bringForward(rect)
    false
  body.on 'click', "#rect_down", =>
    rect = @c.getActiveObject()
    if rect
      @c.sendBackwards(rect)
    false
  body.on 'click', "#rect_add", =>
    create_rect(@c.getActiveObject())
  body.on 'click', "#rect_del", =>
    rect = @c.getActiveObject()
    if rect
      rect.remove()
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

  @cicrle = new fabric.Circle {radius: 200, left: 0, top: 0, opacity: 0}
  @square = new fabric.Rect {width: 400, height: 400, left: 0, top: 0, opacity: 0}
  @baseshapes = [@square, @cicrle]

  @z.add @cicrle
  @z.add @square
  @images = []
  create_image= (img, cb)=>
     new Promise (fulfil, reject) =>
      fabric.Image.fromURL img, (oimg)=>
        fulfil(oimg)

  @rec = 0
  max_rec= ->
    parseInt $('#iterated_function_system_rec_number').val()
  heraks= =>
    if rec == 0
      shape = @baseshapes[ parseInt  $('#iterated_function_system_base_shape').val() ]
      shape.set {opacity: 1}
      @z.renderAll()
    rec+=1
    img = $('#blackbird_fly')[0].toDataURL("image/png")
    @cicrle.set {'opacity': 0}
    @square.set {'opacity': 0}
    simgs=[]
    for rect in @c.getObjects()
      simgs.push img
    Promise.all(simgs.map create_image).then (fabric_images)=>
      for image in @images
        image.remove()
      @images=[]
      for i in [0...fabric_images.length]
        rect = @c.getObjects()[i]
        continue unless rect
        oimg = fabric_images[i]
        hash = {id: rect.id}
        for prop in properties
          hash[prop] = rect[prop]
        oimg.set hash
        @z.add oimg
        @images.push oimg
        @z.renderAll()
      if @rec < max_rec()
        heraks()
      else
        $('#fractal_image').attr 'src', $('#blackbird_fly')[0].toDataURL("image/png")
        $("#iterated_function_system_image").val $('#blackbird_fly')[0].toDataURL("image/png")
        for image in @images
          image.remove()
        @images=[]
        @rec=0
        @z.renderAll()
        heraks()
        
  heraks()
  
