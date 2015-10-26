class Queue
  constructor: ->
    @freq = 10
    @tasks = []
    @start()
  start: ->
    @life = true
    setTimeout @process, @freq
  stop: ->
    @life = false
  clear: ->
    @tasks=[]
  process: =>
    return unless @life
    task = @tasks.shift()
    unless task
      setTimeout @process, @freq
    else
      task.run =>
        @process()
    
      
  push: (args, task)->
    @tasks.push({id: args, run: task})

window.ifs_properties = ['width', 'height', 'left', 'top', 'scaleX', 'scaleY', 'angle', 'flipX', 'flipY', 'x', 'y', 'color', 'originX', 'originY']

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

  # Arguments:
  #  @scope
  #   show_transf: true/false/undefined(don't use it)
  #   depth: integer (default behaviour)
  #   base_shape: 0/1/undefined(default behaviour)
  #   timeout:  integer/undefined(don't use it)
  # canvas_id:  string
  # dest_image: null(don't use it)/string/undefined(default image)
  # dest_input: null(don't use it)/string/undefined(default input)

  constructor: (args = {})->
    @args = args
    @scope = {}
    @scope = @args.scope if @args.scope
    @properties  = ifs_properties
    @canvas_id   = args.canvas_id||'blackbird_fly'
    @jcanvas     = $("##{@canvas_id}")
    @on_completed = args.on_completed
    if args.progress
      @progress = $(args.progress)

    @dest_image  = '#fractal_image'
    @dest_input  = "#iterated_function_system_image"
    if args.dest_image != undefined
      @dest_image  = args.dest_image
    if args.dest_input != undefined
      @dest_input  = args.dest_input

    @width = parseInt @jcanvas.attr 'width'

    @z = new fabric.StaticCanvas @canvas_id, {centeredRotation: true, centeredScaling: true}
    @cicrle = new fabric.Circle {radius: @width/2, left: 0, top: 0, opacity: 0}
    @square = new fabric.Rect {width: @width, height: @width, left: 0, top: 0, opacity: 0}
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
  sepuka: ->
    @queue.stop()
    @queue.clear()
    @z.clear()

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
      if @scope.show_transf
        @show_transf()
      else
        @hide_tranforms()
      on_done()

  render: (pipeline, redraw)->
    @queue.clear() #if redraw
    @rec=0 #if redraw
    i=0
    while i<@max_rec()
      for fractal in pipeline
        return unless i<@max_rec()
        do (fractal)=>
          @queue.push ['t', 0 + @revision ], (on_done)=>
            @set_transforms(fractal.transforms)
            on_done()
          for j in [0...fractal.repeats]
            @queue.push 'h', (on_done)=>
              @heraks(on_done)
            i += 1
            return unless i<@max_rec()
      return if i == 0
    return
        
      
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
    if @scope.show_transf != undefined
      for rect in @rects
        frect = new fabric.Rect rect
        frect.set {stroke: 'red', fill: null}
        frect.setGradient 'fill', {x0: 0, x1: 1, x2:200, y2:200, colorStops: {0: "rgba(10, 20, 30, 0.5)", 1: "white"}}
        @z.add frect
        @transformations.push frect

  max_rec: ->
    if @scope.depth != undefined
      @scope.depth
    else
      parseInt $('#ifs_chain_rec_number').val()

  shape_id: ->
    if @scope.base_shape != undefined
      @scope.base_shape
    else
      shape_no = $('#ifs_chain_base_shape').val()
      parseInt   $('#ifs_chain_base_shape').val()
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
    @colors[sid][color] = @jcanvas[0].toDataURL("image/png")

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
      @rendered_revision = 0+ @revision
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
      img = @jcanvas[0].toDataURL("image/png")
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
        if @progress
          pp = 100.0*@rec/@max_rec()
          @progress.css {width: "#{pp}%"}
      else
        @progress.css {width: "100%"} if @progress
        if @dest_image
          $(@dest_image).attr 'src', @jcanvas[0].toDataURL("image/png")
        if @dest_input
          $(@dest_input).val @jcanvas[0].toDataURL("image/png")
        @rec=0
        @z.renderAll()
        @strip_queue()
      if @scope.show_transf
        @show_transf()
      if @rec == 0 and @on_completed
        @on_completed()
      if on_done
        if @scope.timeout
          setTimeout (=> on_done()), parseInt @scope.timeout
        else
          on_done()
window.IfsRenderer = IfsRenderer

