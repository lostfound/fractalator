jQuery ->
  n = 1
  max_rec = 1
  for g in $("defs g")
    r = parseInt( $(g).attr("id")[3..] )
    max_rec = r if r>max_rec
  animate= =>
    $("#ifs_show").attr "xlink:href", "#rec#{n}"
    n++
    n = 1 if n >max_rec
  setInterval animate,2000
  
