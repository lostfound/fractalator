#= require ifs_likes
#= require fabric
#= require ifs_chain_render
#= require intense
angular.module('ifs',["controllers", 'ngRoute', 'ngTurbolinks'])
controllers = angular.module('controllers',[])
controllers.controller("custom_fractal", [ '$scope',
  (scope)->
  ])
controllers.controller("ifs_controller", [ '$scope',
  (scope)->
    localStorage.ifs_animation_timeout||=200
    localStorage.hr_width||=2000

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
      @hdfs = new IfsRenderer args
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
      
  ])

jQuery ->
  @ifs_scope = $('[ng-controller=ifs_controller]').scope()
  @ifs_eng = new IfsChainRender scope: @ifs_scope
  @ifs_eng.render  @ifs_scope.pipeline, true
  @ifs_scope.$watch 'timeout', (n,o)=>
    localStorage.ifs_animation_timeout = parseInt n
  @ifs_scope.$watch 'hr_width', (n,o)=>
    localStorage.hr_width = parseInt n
  @ifs_scope.$watch 'show_transf', (n,o)=>
    @ifs_eng.show_transformations()
  @ifs_scope.$watch 'depth', (n,o)=>
    console.log "!"
    if on<0 or o<0
      @ifs_eng.render  @ifs_scope.pipeline, true
    else
      @ifs_eng.render  @ifs_scope.pipeline, true
  $("body").off 'click', '#blackbird_fly'
  $("body").on 'click', '#blackbird_fly', =>
    @ifs_eng.render  @ifs_scope.pipeline, true
