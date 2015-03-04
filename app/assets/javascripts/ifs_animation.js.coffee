# require ifs_likes
#= require fabric
#= require ifs_render
angular.module('ifs',["controllers"])
controllers = angular.module('controllers',[])
controllers.controller("ifs_controller", [ '$scope',
  (scope)->
    scope.timeout = 600
    scope.show_transf=false
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
    
      
