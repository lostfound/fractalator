# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  get_current_no= =>
    id= parseInt $(".subheader.current").parents(".transf").attr "data-id"

  $("#ifs_form").submit ->
    transforms = []
    for t in $(".transf")
      tr=$(t)
      tr_hash={}
      tr_hash.num = parseInt tr.attr "data-id"

      for name in ["scale_x", "scale_y", "angle_x", "angle_y", "trans_x", "trans_y"]
        tr_hash[name] = parseFloat tr.find("[name=#{name}]")[0].value
      transforms.push tr_hash
    $(@).find("#iterated_function_system_transforms").val JSON.stringify transforms
    $(@).find("[type=submit]").hide()
    $("#fractal_generation_alert").show()

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

  $(".formations").on "change", ".transf input", ->
    r= $(@).parents(".transf").attr("data-id")
    p = transform(r)
    matrix="matrix(#{p.join(",")})"
    $("use.tr#{r}").attr "transform", matrix

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
    id = get_current_no()
    n = parseInt $(".formations").children().last().attr("data-id")
    n++
    if id
      nt = $(".formations .transf[data-id=#{id}]").clone()
    else
      nt = $(".formations").children().last().clone()
    nt.attr "data-id", n
    nt.find(".subheader").html("Transformation №#{n}")
    nt.find(".subheader").attr "href", "#transf#{n}"
    nt.find(".subheader").removeClass "current"
    nt.find(".content").attr "id", "transf#{n}"
    $(".formations").append nt
    for u in $("use.tr#{id}")
      uu= $(u).clone()
      $(uu).attr "class", "u tr#{n}"
      $(u).parent().append(uu)

  $(".formations").on "click", ".subheader", ->
    rec_no = $("#rec_no")[0].value
    id=$(@).parent().attr("data-id")
    $(".subheader.current").removeClass("current")
    $(@).addClass("current")

    $("use.u").removeAttr "fill"
    $("#rec#{rec_no} use.u").attr "fill", "black"
    $("#rec#{rec_no} use.tr#{id}").attr "fill", "#007095"

  $(".formations").on "click", "[name=destroy]", ->
    p   = $(@).parents(".transf")
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
  is_mouse_down=false
  mouse_start_coords=[0,0]
  $("#mouse_handler").mousedown (e)->
    is_mouse_down=true
    mouse_start_coords=[e.pageX, e.pageY]

  $("#mouse_handler").mouseup (e)->
    return unless is_mouse_down
    is_mouse_down = false
    dlt= [e.pageX - mouse_start_coords[0], e.pageY - mouse_start_coords[1]].map (n)=>(n/300.0).toFixed(3)
    id= get_current_no()
    return unless id
    x = parseFloat $(".transf[data-id=#{id}] [name=trans_x]").val()
    y = parseFloat $(".transf[data-id=#{id}] [name=trans_y]").val()
    x+= parseFloat dlt[0]
    y+= parseFloat dlt[1]
    $(".transf[data-id=#{id}] [name=trans_x]").val(x.toFixed(3))
    $(".transf[data-id=#{id}] [name=trans_y]").val(y.toFixed(3))
    p = transform(id)
    matrix="matrix(#{p.join(",")})"
    $("use.tr#{id}").attr "transform", matrix

