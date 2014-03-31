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

  set_events= =>
    $(".transf input").unbind 'click'
    $(".transf input").change ->
      r= $(@).parents(".transf").attr("data-id")
      p = transform(r)
      matrix="matrix(#{p.join(",")})"
      $("use.tr#{r}").attr "transform", matrix

  set_events()

  $("#rec_no").change ->
    n = parseInt @.value
    for g in $("defs g")
      gid = parseInt $(g).attr("id")[3..]
      if gid > 1 and gid >n
        $(g).remove()
    fr=$("defs #rec1")
    for i in [1..n]
      if $("defs #rec#{i}").length < 1
        frr = fr.clone()
        frr.attr "id", "rec#{i}"
        frr.find("use").attr "xlink:href", "#rec#{i-1}"
        frr.find("use").attr "class", "u rec#{i}"
        $("defs").append frr
        
        
    $("use.u").removeAttr "fill"
    $("#rec#{n} use.u").attr "fill", "black"
    $("#ifs_show").attr "xlink:href", "#rec#{n}"

  $("#add_transf").click ->
    n = parseInt $(".formations").children().last().attr("data-id")
    n++
    nt = $(".formations").children().last().clone()
    nt.attr "data-id", n
    nt.find(".subheader").html("Transformation №#{n}")
    nt.find(".subheader").attr "href", "#transf#{n}"
    nt.find(".content").attr "id", "transf#{n}"
    $(".formations").append nt
    for u in $("use.tr#{n-1}")
      uu= $(u).clone()
      $(uu).attr "class", "u tr#{n}"
      $(u).parent().append(uu)
    set_events()
    $(".transf[data-id=#{n}] [name=destroy]").click ->
      destroy_transformation @
    #Foundation.libs.accordion.events()
    
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
  #$("#iterated_function_system_base_shape").change ->
  #  shape_id= parseInt $(@).val()
  #  if shape_id == 0
  #    $("g#rec0").children().remove()
  #    $("g#rec0").append($('<rect x="0" y="0" width="1" height="1"/>'))

  #  else
  #    $("g#rec0").html('<circle cy="0.5" cx="0.5" r="0.5"/>')
