#= require ifs_likes
#= require fabric
#= require ifs_render
#= require intense
angular.module('ifs',["controllers"])
controllers = angular.module('controllers',[])
controllers.controller("custom_fractal", [ '$scope',
  (scope)->
  ])
controllers.controller("ifs_controller", [ '$scope',
  (scope)->
    scope.timeout = 60
    scope.show_transf=false
    scope.hr_width = 2000
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
      transforms = []
      for o in scope.transforms
        tr = fobj_to_hash o
        tr.width = scope.hr_width/2
        tr.height = scope.hr_width/2
        scale_factor = scope.hr_width/400.0
        tr.left = tr.left*scale_factor
        tr.top = tr.top*scale_factor
        transforms.push tr
      @hdfs.render transforms
      
  ])

jQuery ->
  @ifs_scope = $('[ng-controller=ifs_controller]').scope()
  @ifs_eng = new IfsRenderer {scope: @ifs_scope}
  @ifs_eng.render  @ifs_scope.transforms, true
  @ifs_scope.$watch 'show_transf', (n,o)=>
    @ifs_eng.show_transformations()
  @ifs_scope.$watch 'depth', (n,o)=>
    if on<0 or o<0
      @ifs_eng.render  @ifs_scope.transforms, true
    else
      @ifs_eng.render  @ifs_scope.transforms, true
  $("body").off 'click', '#blackbird_fly'
  $("body").on 'click', '#blackbird_fly', =>
    @ifs_eng.render  @ifs_scope.transforms, true
    
      
