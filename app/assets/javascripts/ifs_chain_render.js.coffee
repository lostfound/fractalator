
class IfsChainRender extends IfsRenderer

  render: (pipeline, redraw)->
    @queue.clear() #if redraw
    @rec=0 #if redraw
    i=0
    ppl = ( fr for fr in pipeline when fr.repeats and fr.repeats > 0 )
    for fr in pipeline
      fr.selected = false
    return if ppl.length == 0
    while i<@max_rec()
      for fractal in ppl
        unless i<@max_rec()
          fractal.selected = true
          return
        do (fractal)=>
          @queue.push ['t', 0 + @revision ], (on_done)=>
            @set_transforms(fractal.transforms)
            on_done()
          for j in [0...fractal.repeats]
            @queue.push 'h', (on_done)=>
              @heraks(on_done)
            i += 1
            unless i<@max_rec()
              fractal.selected = true
              fractal.last = j == fractal.repeats - 1
              return
        return unless i<@max_rec()
      return if i == 0

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
window.IfsChainRender = IfsChainRender
