class Queue
  constructor: ->
    @freq = 10
    @tasks = []
    @start()
  start: ->
    setTimeout @process, @freq
  clear: ->
    @tasks=[]
  process: =>
    task = @tasks.shift()
    unless task
      setTimeout @process, @freq
    else
      task.run =>
        @process()
    
      
  push: (args, task)->
    @tasks.push({id: args, run: task})
window.ifs_properties = ['width', 'height', 'left', 'top', 'scaleX', 'scaleY', 'angle', 'flipX', 'flipY', 'x', 'y', 'color']
window.fobj_to_hash= (rect)->
  hash = {}
  for prop in ifs_properties
    hash[prop] = rect[prop]
  hash

class IfsRenderer
  #Example:
  # ifsr = new IfsRenderer
  # ifsr.set_transforms @c.getObjects()
  # ifsr.heraks()

  constructor: (args = {})->
    @args = args
    @scope = @args.scope if @args.scope
    @properties = ifs_properties
    @z = new fabric.StaticCanvas 'blackbird_fly', {centeredRotation: true, centeredScaling: true}
    @cicrle = new fabric.Circle {radius: 200, left: 0, top: 0, opacity: 0}
    @square = new fabric.Rect {width: 400, height: 400, left: 0, top: 0, opacity: 0}
    @baseshapes = [@square, @cicrle]
    @revision = 0
    @rendered_revision = 0
    @images = []
    @z.add @cicrle
    @z.add @square
    @rec = 0
    @lock = false
    @restart = false
    @transformations = []

    @queue = new Queue

  strip_queue: ->
    last_t = null
    for i in [0...@queue.tasks.length]
      if @queue.tasks[i].id[0] == 't'
        last_t=i
    return if last_t == null
    for i in [0...last_t]
      @queue.tasks.shift i
  show_transformations: ->
    @queue.push ['s',0], (on_done)=>
      if @scope and @scope.show_transf
        @show_transf()
      else
        @hide_tranforms()
      on_done()

  render: (rects, redraw)->
    @queue.clear() if redraw
    @queue.push ['t', 0 + @revision ], (on_done)=>
      @rec=0 if redraw
      @set_transforms(rects)
      on_done()
    for i in [0...@max_rec()]
      @queue.push 'h', (on_done)=>
        @heraks(on_done)

  set_transforms: (rects)->
    @revision += 1
    @rects = ( fobj_to_hash(rect) for rect in rects )
    for transf in @transformations
      transf.remove()
    @transformations=[]
    if @scope and @scope.show_transf != undefined
      for rect in @rects
        frect = new fabric.Rect rect
        frect.set {stroke: 'red', fill: null}
        @z.add frect
        @transformations.push frect

  max_rec: ->
    if @scope
      @scope.depth
    else
      parseInt $('#iterated_function_system_rec_number').val()

  shape_id: ->
    if @scope
      @scope.base_shape
    else
      parseInt  $('#iterated_function_system_base_shape').val()
  baseshape: ->
      @baseshapes[ @shape_id() ]

  #rect_dup: (rect)->
  #  hash = {}
  #  for prop in @properties
  #    hash[prop] = rect[prop]
  #  hash

  create_image: (img, cb)=>
     new Promise (fulfil, reject) =>
      fabric.Image.fromURL img, (oimg)=>
        fulfil(oimg)

  first_image: (color, sid)->
    @colors[sid]||={}
    if img = @colors[sid][color]
      return img
    
    @cicrle.set {'opacity': 0, fill: color}
    @square.set {'opacity': 0, fill: color}
    shape = @baseshape()
    shape.set {opacity: 1}
    @z.renderAll()
    @colors[sid][color] = $('#blackbird_fly')[0].toDataURL("image/png")

  hide_tranforms: ->
    for transf in @transformations
      transf.set {opacity: 0.0}
    @z.renderAll()
  show_transf: ->
    for transf in @transformations
      transf.set {opacity: 1}
      transf.bringToFront()
    @z.renderAll()
    
  heraks: (on_done)->
    @hide_tranforms()
    simgs=[]
    if @rec == 0
      for image in @images
        image.remove()
      @images=[]
      @rendered_revision = @revision
      @colors = {}
      sid = @shape_id()
      for rect in @rects
        continue unless rect.color
        @first_image rect.color, sid
      @first_image "#000", sid

      @cicrle.set {'opacity': 0}
      @square.set {'opacity': 0}
      for rect in @rects
        img = @colors[sid][rect.color]||@colors[sid]["#000"]
        simgs.push img
    else
      img = $('#blackbird_fly')[0].toDataURL("image/png")
      #Create images
      for rect in @rects
        simgs.push img
    @rec+=1

    Promise.all(simgs.map @create_image).then (fabric_images)=>
      for image in @images
        image.remove()
      @images=[]
      for i in [0...fabric_images.length]
        rect = @rects[i]
        continue unless rect
        oimg = fabric_images[i]
        oimg.set rect
        @z.add oimg
        @images.push oimg
        @z.renderAll()
      if @rec < @max_rec()
      else
        $('#fractal_image').attr 'src', $('#blackbird_fly')[0].toDataURL("image/png")
        $("#iterated_function_system_image").val $('#blackbird_fly')[0].toDataURL("image/png")
        @rec=0
        @z.renderAll()
        @strip_queue()
      if @scope and @scope.show_transf
        @show_transf()
      if on_done
        if @scope and @scope.timeout
          setTimeout (=> on_done()), parseInt @scope.timeout
        else
          on_done()
window.IfsRenderer = IfsRenderer

