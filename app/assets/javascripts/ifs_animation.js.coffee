jQuery ->
  n = 1
  animate= =>
    $("#ifs_show").attr "xlink:href", "#rec#{n}"
    n++
    n = 1 if n >6
  setInterval animate,2000
  
