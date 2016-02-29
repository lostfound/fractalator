#= require ifs_likes
#= require fabric
#= require ifs_chain_render
#= require intense
#= require jquery-ui/core
#= require jquery-ui/widget
#= require jquery-ui/mouse
#= require jquery-ui/position
#= require jquery-ui/button
#
#= require evol.colorpicker
angular.module('ifs',["controllers"])
controllers = angular.module('controllers',[])
controllers.controller("custom_fractal", [ '$scope',
  (scope)->
  ])
first_skip=true
ifs_eng = null
$(document).on 'page:change', ->
  if ifs_eng and not first_skip
    ifs_eng.sepuka()
    ifs_eng = null
  first_skip = false

controllers.controller("ifs_animation", [ '$scope',
  (scope)->
    localStorage.ifs_animation_timeout||=200
    localStorage.hr_width||=2000
    data = $("[data-json]").data('json')
    $("#color").colorpicker()

    for k, v of data
      scope[k] = v

    scope.timeout = parseInt localStorage.ifs_animation_timeout
    scope.show_transf=false
    scope.hr_width = parseInt localStorage.hr_width
    scope.instanced = false
    scope.hr_depth = scope.depth
    scope.make_hr= =>
      $('body').addClass 'body_blocked'
      args = {}
      args.scope ={}
      args.scope.base_shape = scope.base_shape
      args.scope.depth = scope.hr_depth
      args.canvas_id   = 'render_hd'
      args.dest_image  = '#fractal_hd'
      args.dest_input  = null
      args.progress = ".progress .meter"
      args.on_completed= =>
        Intense $('#fractal_hd')[0] unless scope.instanced
        scope.instanced = true
        $(args.dest_image).click()
        @hdfs.sepuka()
        $('body').removeClass 'body_blocked'
      $("##{args.canvas_id}").attr 'width', scope.hr_width
      $("##{args.canvas_id}").attr 'height', scope.hr_width
      @hdfs = new IfsRenderer args
      transforms = []
      for o in scope.transforms
        tr = fobj_to_hash o
        tr.width = scope.hr_width/2
        tr.height = scope.hr_width/2
        scale_factor = scope.hr_width/400.0
        tr.left = tr.left*scale_factor
        tr.top = tr.top*scale_factor
        tr.stroke_width = tr.stroke_width*scale_factor if tr.stroke_width
        transforms.push tr
      @hdfs.set_bg_color $("#color").val()
      @hdfs.render transforms
      

    ifs_eng = new IfsRenderer {scope: scope}
    #ifs_eng.render  scope.transforms, true
    scope.$watch 'timeout', (n,o)=>
      localStorage.ifs_animation_timeout = parseInt n
    scope.$watch 'hr_width', (n,o)=>
      localStorage.hr_width = parseInt n
    scope.$watch 'show_transf', (n,o)=>
      ifs_eng.show_transformations()
    scope.$watch 'depth', (n,o)=>
      if on<0 or o<0
        ifs_eng.render  scope.transforms, true
      else
        ifs_eng.render  scope.transforms, true
    $("body").off 'click', '#blackbird_fly'
    $("body").on 'click', '#blackbird_fly', =>
      ifs_eng.render  scope.transforms, true
    
  ])

controllers.controller("ifs_chain_animation", [ '$scope',
  (scope)->
    $("#color").colorpicker()
    localStorage.ifs_animation_timeout||=200
    localStorage.hr_width||=2000
    data = $("[data-json]").data('json')
    for k, v of data
      scope[k] = v

    scope.timeout = parseInt localStorage.ifs_animation_timeout
    scope.show_transf=false
    scope.hr_width = parseInt localStorage.hr_width
    scope.instanced = false
    scope.make_hr= =>
      $('body').addClass 'body_blocked'
      args = {}
      args.scope ={}
      args.scope.base_shape = scope.base_shape
      args.scope.depth = scope.hr_depth
      args.canvas_id   = 'render_hd'
      args.dest_image  = '#fractal_hd'
      args.dest_input  = null
      args.progress = ".progress .meter"
      args.on_completed= =>
        Intense $('#fractal_hd')[0] unless scope.instanced
        scope.instanced = true
        $(args.dest_image).click()
        @hdfs.sepuka()
        $('body').removeClass 'body_blocked'
      $("##{args.canvas_id}").attr 'width', scope.hr_width
      $("##{args.canvas_id}").attr 'height', scope.hr_width
      @hdfs = new IfsChainRender args
      @hdfs.set_bg_color $("#color").val()
      hr_pipeline = []
      for part in scope.pipeline
        transforms = []
        for o in part.transforms
          tr = fobj_to_hash o
          tr.width = scope.hr_width/2
          tr.height = scope.hr_width/2
          scale_factor = scope.hr_width/400.0
          tr.left = tr.left*scale_factor
          tr.top = tr.top*scale_factor
          transforms.push tr
        hr_pipeline.push {transforms: transforms, repeats: part.repeats}
      @hdfs.render hr_pipeline, true
      
    ifs_eng = new IfsChainRender scope: scope
    ifs_eng.render  scope.pipeline, true
    scope.$watch 'timeout', (n,o)=>
      localStorage.ifs_animation_timeout = parseInt n
    scope.$watch 'hr_width', (n,o)=>
      localStorage.hr_width = parseInt n
    scope.$watch 'show_transf', (n,o)=>
      ifs_eng.show_transformations()
    scope.$watch 'depth', (n,o)=>
      if on<0 or o<0
        ifs_eng.render  scope.pipeline, true
      else
        ifs_eng.render  scope.pipeline, true
    $("body").off 'click', '#blackbird_fly'
    $("body").on 'click', '#blackbird_fly', =>
      ifs_eng.render  scope.pipeline, true
  ])
