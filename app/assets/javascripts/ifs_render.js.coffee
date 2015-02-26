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
class IfsRenderer
  #Example:
  # ifsr = new IfsRenderer
  # ifsr.set_transforms @c.getObjects()
  # ifsr.heraks()

  constructor: ->
    @properties = ['width', 'height', 'left', 'top', 'scaleX', 'scaleY', 'angle', 'flipX', 'flipY', 'x', 'y']
    @z = new fabric.Canvas 'blackbird_fly', {centeredRotation: true, centeredScaling: true}
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

    @queue = new Queue

  strip_queue: ->
    last_t = null
    for i in [0...@queue.tasks.length]
      if @queue.tasks[i].id[0] == 't'
        last_t=i
    return if last_t == null
    for i in [0...last_t]
      @queue.tasks.shift i
    #console.log "STRIP #{last_t} #{@queue.tasks.length}"

  render: (rects, redraw)->
    @queue.clear() if redraw
    @queue.push ['t', 0 + @revision ], (on_done)=>
      @rec=0 if redraw
      @set_transforms(rects)
      on_done()
    for i in [0...@max_rec()]
      @queue.push 'h', (on_done)=>
        @heraks(on_done)

    #@queue.push 'd', (on_done)=>
    #  console.log "recursins: #{@rec}"
    #  on_done()

  set_transforms: (rects)->
    @revision += 1
    @rects = ( @rect_dup(rect) for rect in rects )

  max_rec: ->
    parseInt $('#iterated_function_system_rec_number').val()

  baseshape: ->
      @baseshapes[ parseInt  $('#iterated_function_system_base_shape').val() ]

  rect_dup: (rect)->
    hash = {}
    for prop in @properties
      hash[prop] = rect[prop]
    hash

  create_image: (img, cb)=>
     new Promise (fulfil, reject) =>
      fabric.Image.fromURL img, (oimg)=>
        fulfil(oimg)

  heraks: (on_done)->
    if @rec == 0
      @rendered_revision = @revision
      shape = @baseshape()
      shape.set {opacity: 1}
      @z.renderAll()
    @rec+=1
    img = $('#blackbird_fly')[0].toDataURL("image/png")
    @cicrle.set {'opacity': 0}
    @square.set {'opacity': 0}
    simgs=[]
    #Create images
    for rect in @rects
      simgs.push img

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
        for image in @images
          image.remove()
        @images=[]
        @rec=0
        @z.renderAll()
        @strip_queue()
      on_done() if on_done
  window.IfsRenderer = IfsRenderer

