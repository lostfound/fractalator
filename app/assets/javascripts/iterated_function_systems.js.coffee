# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $("#ifs_form").submit ->
    transforms = []
    for t in $(".transf")
      tr=$(t)
      transform={}
      transform.num = parseInt tr.attr "data-id"

      for name in ["scale_x", "scale_y", "angle_x", "angle_y", "trans_x", "trans_y"]
        transform[name] = parseFloat tr.find("[name=#{name}]")[0].value
      transforms.push transform
    $(@).find("#iterated_function_system_transforms").val JSON.stringify transforms

  transform= (num)=>
    params=[]
    for name in ["scale_x", "scale_y", "angle_x", "angle_y", "trans_x", "trans_y"]
      params[name] = parseFloat $(".transf[data-id=#{num}] [name=#{name}]")[0].value
    t=[]
    a = params.scale_x*Math.cos(params.angle_x*Math.PI/180)
    b = params.scale_x*Math.sin(params.angle_x*Math.PI/180)
    c = params.scale_y*Math.sin(params.angle_y*Math.PI/180) * -1
    d = params.scale_y*Math.cos(params.angle_y*Math.PI/180)
    [a.toFixed(3), b.toFixed(3), c.toFixed(3), d.toFixed(3), params.trans_x.toFixed(3), params.trans_y.toFixed(3)]

  r = 1
  chrec= =>
    $('#ifs_show').attr "xlink:href", "#rec#{r}"
    r++
    r=1 if r>5

  set_events= =>
    $(".transf input").unbind 'click'
    $(".transf input").change ->
      r= $(@).parents(".transf").attr("data-id")
      p = transform(r)
      matrix="matrix(#{p.join(",")})"
      $("use.tr#{r}").attr "transform", matrix

  set_events()
  #for i in [1..3]
  #  $($(".transf[data-id=#{i}] input")[0]).change()

  $("#rec_no").change ->
    n = parseInt @.value
    $("use.u").removeAttr "fill"
    $("#rec#{n} use.u").attr "fill", "black"
    $("#ifs_show").attr "xlink:href", "#rec#{n}"

  $("#add_transf").click ->
    n = parseInt $(".formations").children().last().attr("data-id")
    n++
    nt = $(".formations").children().last().clone()
    nt.attr "data-id", n
    nt.children(".subheader.text-right").html("Transformation №#{n}")
    $(".formations").append nt
    for u in $("use.tr#{n-1}")
      uu= $(u).clone()
      $(uu).attr "class", "u tr#{n}"
      $(u).parent().append(uu)
    set_events()
    $(".transf[data-id=#{n}] [name=destroy]").click ->
      destroy_transformation @
    
  on_bayan=(b) =>
    rec_no = $("#rec_no")[0].value
    id=$(b).parent().attr("data-id")
    $("use.u").removeAttr "fill"
    $("#rec#{rec_no} use.u").attr "fill", "black"
    $("#rec#{rec_no} use.tr#{id}").attr "fill", "#007095"
  $(".subheader").click ->
    on_bayan(@)

  destroy_transformation= (trf) =>
    p   = $(trf).parents(".transf")
    id  = parseInt p.attr 'data-id'
    $(".u.tr#{id}").remove()
    for t in $(".transf")
      tr = $(t)
      tid = parseInt tr.attr 'data-id'
      if tid > id
        tr.attr 'data-id', tid-1
        sh = tr.find('.subheader')
        sh.attr href="#transf#{tid-1}"
        sh.html "Transformation №#{tid-1}"
        for use in $("use.u.tr#{tid}")
          use.setAttribute "class", "u tr#{tid-1}"
    p.remove()
  $("[name=destroy]").click ->
    destroy_transformation(@)
