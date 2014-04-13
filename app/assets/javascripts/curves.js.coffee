jQuery ->
  control_type= => $('.control.panel .icon_button.selected').attr 'id'
  get_pos= (e, node)=>
   offset = $(node).offset()
   [e.pageX - offset.left, e.pageY-offset.top]

  make_svg_element= (tag, attrs)=>
    element = document.createElementNS 'http://www.w3.org/2000/svg', tag
    for k in Object.keys(attrs)
      element.setAttribute k, attrs[k]
    element
  P_SEL=3
  P_TYPE=2
  points = {0: [300,300,"center", false]}
  points[1]=[100,300,"start",  false]
  points[2]=[500,300,"finish", false]
  lines  = {}
  plines = {}
  l_counter = 0
  p_counter = 3
  points_sequence=[]
  history=[]
  history_pos=0

  clone= (a)=>
    return JSON.parse JSON.stringify a
    #jQuery.extend true, {}, @
    
  #history helper
  history_push= =>
    snapshot={}
    snapshot.points = clone(points)
    snapshot.lines  = clone(lines)
    snapshot.plines = clone(plines)
    snapshot.l_counter = clone(l_counter)
    snapshot.points_sequence = clone(points_sequence)
    if history.length == history_pos
      history.push(snapshot)
    else
      history = history[..history_pos-1]
      history.push snapshot
    history_pos++
    $("#debug").html("#{history_pos} #{history.length}")

  resvg= =>
    $("#pnumbers").children().remove()
    $("#lines").children().remove()
    $(".points").children().remove()
    for pid in Object.keys(points)
      p = points[pid]
      point = make_svg_element 'circle', {cx: p[0], cy: p[1], r: 10, "data-id": pid}
      if p[3]
        n = points_sequence.indexOf parseInt pid
        n++
        point.setAttribute "selected", ""
        txt = make_svg_element 'text', {x: p[0], y: p[1], "data-id": pid, "font-size": "10px"}
        txt.appendChild( document.createTextNode("#{n}") )
        $("#pnumbers").append txt
      if p[2]
        point.setAttribute "class", p[2]

      $(".points").append point

    for lid in Object.keys(lines)
      l = lines[lid]
      ap=points[l[0]]
      bp=points[l[1]]
      line= make_svg_element "line", {x1: ap[0], y1: ap[1], x2: bp[0], y2: bp[1], "data-id": lid, "marker-start": "url(#markerCircle)", "marker-end": "url(#markerArrow)" }
      $("#lines").append line

    when_point_selected()


  history_redo= =>
    return if history_pos >= history.length
    snapshot = clone(history[history_pos])
    history_pos++
    points = snapshot.points
    lines = snapshot.lines
    plines = snapshot.plines
    l_counter = snapshot.l_counter
    points_sequence = snapshot.points_sequence
    resvg()
    $("#debug").html("#{history_pos} #{history.length}")
  history_undo= =>
    return if history_pos <= 0
    history_pos--
    snapshot = clone(history[history_pos-1])
    points = snapshot.points
    lines = snapshot.lines
    plines = snapshot.plines
    l_counter = snapshot.l_counter
    points_sequence = snapshot.points_sequence
    resvg()
    $("#debug").html("#{history_pos} #{history.length}")
  

  insert_line_to_table= (lid, table)=>
    line = lines[lid]
    a = points[line[0]]
    b = points[line[1]]

    trline = $("#line_template").clone()
    trline.attr("data-id", lid)
    trline.removeAttr 'id'
    trline.show()
    trline.find('.direction').html "(#{parseInt a[0]},#{parseInt a[1]})-(#{parseInt b[0]},#{parseInt b[1]})"
    if line[2]['flipx']
      $(trline.find('.flipx')).prop('checked', true)
    if line[2]['flipy']
      $(trline.find('.flipy')).prop('checked', true)
    trline.show()
    table.append trline

  update_lines_table= =>
    table = $('.table.lines')
    if points_sequence.length > 2 or points_sequence.length ==0
      return table.hide()
    else
      aid = points_sequence[0]

      if points_sequence.length == 1
        lns = plines[aid]
        if !lns or lns.length == 0
          return table.hide()
        else
          tlns = []
          for lid in lns
            if lines[lid][0] == aid
              tlns.push lid
          if tlns.length == 0
            return table.hide()
          else
            table.find('tr[data-id]').remove()
            for lid in tlns
              insert_line_to_table lid, table

            return table.show()
      else
        bid = points_sequence[1]
        lns = plines[aid]
        return table.hide() unless lns
        return table.hide() unless plines[bid]
        llns=[]
        for lid in lns
          if lid in plines[bid] and lines[lid][0] == aid
            llns.push lid
        lns = llns
        if !lns or lns.length == 0
          return table.hide()
        table.find('tr[data-id]').remove()
        for lid in lns
          insert_line_to_table lid, table
        return table.show()
  #lines helper
  create_line= (a,b)=>
    lid=l_counter
    l_counter++
    lines[lid] = [a,b,{}]
    plines[a]=[] unless plines[a]
    plines[a].push lid
    plines[b]=[] unless plines[b]
    plines[b].push lid
    ap=points[a]
    bp=points[b]
    line= make_svg_element "line", {x1: ap[0], y1: ap[1], x2: bp[0], y2: bp[1], "data-id": lid, "marker-start": "url(#markerCircle)", "marker-end": "url(#markerArrow)"}
    $("#lines").append line

  # pid - point's id, xy = point's coords
  update_svg_line= (pid, xy)=>
    return unless plines[pid]
    for lid in plines[pid]
      line = $("#lines [data-id=#{lid}]")
      ln=lines[lid]
      if ln[0]==pid
        line.attr "x1", xy[0]
        line.attr "y1", xy[1]
      else
        line.attr "x2", xy[0]
        line.attr "y2", xy[1]

    

  delete_line= (lid)=>
    line = lines[lid]
    for pid in [line[0], line[1]]
      plines[pid].splice plines[pid].indexOf(lid), 1
    $("#lines [data-id=#{lid}]").remove()
    delete lines[lid]

  delete_line_by_point= (pid)=>
    if plines[pid]
      for lid in plines[pid].slice(0)
        delete_line lid
      delete plines[pid]

  #points helper
  xyseq= (i)=>
    points[points_sequence[i]][..1]
  
  ab_seq_angle= (a,b)=>
    dx = xyseq(b)[0] - xyseq(a)[0]
    dy = xyseq(b)[1] - xyseq(a)[1]
    phi=(Math.atan2(dy,dx)/Math.PI)*180
  ab_seq_length= (a,b)=>
    axy=xyseq(a)
    bxy=xyseq(b)
    Math.sqrt (axy[0]-bxy[0])**2+(axy[1] - bxy[1])**2
  selected_points= => $(".points circle[selected]")
  add_point= (x,y)=>
    point = make_svg_element 'circle', {cx: x, cy: y, r: 10, "data-id": p_counter}
    $(".points").append $(point)
    points[p_counter]= [x, y, null, false]
    p_counter++

  ch_coords= (pid, x, y)=>
    point = $(".points circle[data-id=#{pid}]")
    text  = $("#pnumbers [data-id=#{pid}]")
    if x!=null
      points[pid][0]=x
      point.attr "cx", x
      text.attr "x", x
    if y!=null
      points[pid][1] = y
      point.attr "cy", y
      text.attr  "y", y
    update_svg_line pid, points[pid]

  #Move Elements
  $("#canvas").mousedown (e)->
   type = control_type()
   xy = get_pos e,@
   if type == 'new_point'
     add_point xy[0], xy[1]
     history_push()

  move_down = false
  move_start_pos = []
  $("#mouse_handler").mousedown (e)->
    move_down=true
    move_start_pos = get_pos e, @

  $("#mouse_handler").mouseup (e)->
    move_down=false
    xy = get_pos e, @
    dx = xy[0] - move_start_pos[0]
    dy = xy[1] - move_start_pos[1]
    for p in selected_points()
      jp = $(p)
      id = parseInt jp.attr "data-id"
      jp.attr( "cx", points[id][0] += dx)
      jp.attr( "cy", points[id][1] += dy)
      pn = $("#pnumbers [data-id=#{id}]")
      pn.attr "x",  points[id][0]
      pn.attr "y",  points[id][1]
    history_push()
    if points_sequence.length == 1
      point = points[points_sequence[0]]
      $("#coord_x_val").val point[0]
      $("#coord_y_val").val point[1]

      
  $("#mouse_handler").mousemove (e)->
    return unless move_down
    xy = get_pos e, @
    dx = xy[0] - move_start_pos[0]
    dy = xy[1] - move_start_pos[1]
    for p in selected_points()
      jp = $(p)
      id = parseInt jp.attr "data-id"
      x = points[id][0] + dx
      y = points[id][1] + dy
      jp.attr "cx", x
      jp.attr "cy", y
      pn = $("#pnumbers [data-id=#{id}]")
      pn.attr "x", x
      pn.attr "y", y
      update_svg_line id, [x,y]



    
  add_point_to_sequence= (id)=>
    points_sequence.push id
    n=points_sequence.length
    [x,y] = points[id][0..1]
    txt = make_svg_element 'text', {x: x, y: y, "data-id": id, "font-size": "10px"}
    txt.appendChild( document.createTextNode("#{n}") )
    $("#pnumbers").append txt
  rm_point_from_sequence= (id)=>
    i = points_sequence.indexOf id
    if i>=0
      points_sequence.splice i, 1
      $("#pnumbers [data-id=#{id}]").remove()
      for pn in $("#pnumbers").children()
        id = parseInt $(pn).attr "data-id"
        pn.childNodes[0].nodeValue = "#{points_sequence.indexOf(id) + 1}"
      true
    else
      false

  # When point clicked
  $('.points').on 'mousedown', 'circle', ->
    type=$('.control.panel .icon_button.selected').attr 'id'
    id = parseInt $(@).attr "data-id"
    if type == 'erase'
      return if $(@).attr('class') in ['center', 'start', 'finish']
      delete_line_by_point id
      delete points[id]
      rm_point_from_sequence id
      $(@).remove()
      when_point_selected()
      return history_push()

    unless @.hasAttribute "selected"
      @.setAttribute "selected", ""
      points[id][P_SEL]=true
      add_point_to_sequence id
    else
      @.removeAttribute "selected"
      points[id][P_SEL]=false
      rm_point_from_sequence id
    when_point_selected()
    history_push()

  #Control panel
  #Point selection
  when_point_selected= =>
    l = points_sequence.length
    update_lines_table()
    if l == 1
      point = points[points_sequence[0]]
      $("#coord_x_val").val point[0]
      $("#coord_y_val").val point[1]
      $("#coord_x").show()
      $("#coord_y").show()
    else
      $("#coord_x").hide()
      $("#coord_y").hide()
    if l > 0
      $("#move").show()
      $("#clear").show()
    else
      $("#move").hide()
      $("#clear").hide()
    if l == 2
      $("#line").show()
    else
      $("#line").hide()
    if l>=1 and l<3
      if l == 1
        pid=points_sequence[0]
        if plines[pid] and plines[pid].length > 0
          $("#rmline").show()
        else
          $("#rmline").hide()
      else
        [pid,pid1]=points_sequence
        if plines[pid] and plines[pid].length > 0 and plines[pid1] and plines[pid1].length > 0
          has_lines=false
          for ln in plines[pid]
            if ln in plines[pid1]
              has_lines = true
              break
          if has_lines
            $("#rmline").show()
          else
            $("#rmline").hide()
        else
          $("#rmline").hide()
    else
      $("#rmline").hide()
      
    if l>=2
      $("#align_x").show()
      $("#align_y").show()
      $("#length_val").val(ab_seq_length(0,1).toFixed 3)
      $("#length_pair").show()
      if l == 2
        phi = ab_seq_angle 0,1
        $("#angle_val").val parseFloat(phi).toFixed 3
      $("#angle_pair").show()
    else
      $("#align_x").hide()
      $("#align_y").hide()
      $("#length_pair").hide()
      $("#angle_pair").hide()

  $("#coord_x_val").change ->
    point = points[points_sequence[0]]
    ch_coords points_sequence[0], parseFloat($(@).val()), point[1]
    history_push()

  $("#coord_y_val").change ->
    point = points[points_sequence[0]]
    ch_coords points_sequence[0], point[0], parseFloat($(@).val())
    history_push()

  $("#angle_val").change ->
    prev_phi = ab_seq_angle(0,1)*Math.PI/180
    phi = parseInt($("#angle_val").val())*Math.PI/180
    dphi = phi - prev_phi
    l=ab_seq_length 0,1
    dy = Math.sin(phi)*l
    dx = Math.cos(phi)*l
    xy = xyseq(0)
    old_xy = xyseq(1)
    ch_coords points_sequence[1], xy[0]+dx, xy[1]+dy
    for id in points_sequence[2..]
      i = points_sequence.indexOf id
      p = points[id]
      l=ab_seq_length 0,i
      phi = ab_seq_angle(0,i)*Math.PI/180 + dphi
      dy = Math.sin(phi)*l
      dx = Math.cos(phi)*l
      ch_coords id, xy[0]+dx, xy[1]+dy
    history_push()
    $("#debug").html(dphi)

  $("#length_val").change ->
    l  = parseFloat $(@).val()
    dx = xyseq(1)[0] - xyseq(0)[0]
    dy = xyseq(1)[1] - xyseq(0)[1]
    phi= Math.atan2(dy,dx)

    dx= Math.cos(phi)*l
    dy= Math.sin(phi)*l
    xy = xyseq(0)
    xy1 = xyseq(1)
    ddx=dx+xy[0]-xy1[0]
    ddy=dy+xy[1]-xy1[1]

    for id in points_sequence[1..-1]
      xy = points[id]
      ch_coords id, xy[0]+ddx, xy[1]+ddy
    history_push()

  #Control panel
  $(".control.panel").on 'click', '.icon_button', ->
    id = $(@).attr 'id'
    name=$(@).attr "id"
    if $(@).hasClass 'command'
      if name == "line"
        create_line points_sequence[0], points_sequence[1]
        when_point_selected()
      else if name == "align_x"
        y0 = points[points_sequence[0]][1]
        for pid in points_sequence
          ch_coords pid, null, y0
      else if name == "align_y"
        x0 = points[points_sequence[0]][0]
        for pid in points_sequence
          ch_coords pid, x0, null
      else if name == "clear"
        for p in selected_points()
          id = parseInt $(p).attr 'data-id'
          points[id][P_SEL]=false
          rm_point_from_sequence id
        $(".points [selected]").removeAttr "selected"
        points_sequence=[]
      else if name == 'rmline'
        if points_sequence.length == 1
          rmlines = clone plines[points_sequence[0]]
        else
          rmlines = []
          for lid in plines[points_sequence[0]]
            if lid in plines[points_sequence[1]]
              rmlines.push lid
        for lid in rmlines
          delete_line lid
        when_point_selected()
      else if name == 'undo'
        return history_undo()
      else if name == 'redo'
        return history_redo()

      history_push()
      return
    $(@).toggleClass "selected"
    $(".control.panel .icon_button.selected:not(##{id})").removeClass("selected")

    if name=="move"
      if $(@).hasClass "selected"
        $("#mouse_handler").show()
      else
        $("#mouse_handler").hide()
    else
      $("#mouse_handler").hide()
  #lines section
  $(".lines").on "click", '.destroy', ->
    lid = parseInt $(@).parents(".line").attr "data-id"
    delete_line lid
    update_lines_table()
    history_push()
  $(".lines").on "change", '[type=checkbox]', ->
    lid = parseInt $(@).parents(".line").attr "data-id"
    line = lines[lid]
    checked = $(@).prop 'checked'
    cls = 'flipx'
    cls = 'flipy' if  $(@).hasClass('flipy')

    if checked
      line[2][cls] = true
    else
      delete line[2][cls]
    history_push()

  $(document).on "keydown", null, "ctrl+c", ->
    if $(".control.panel #clear").is(":visible")
      $(".control.panel #clear").click()

  $(document).on "keydown", null, "ctrl+z", ->
    history_undo()
  $(document).on "keydown", null, "ctrl+y", ->
    history_redo()

  history_push()

