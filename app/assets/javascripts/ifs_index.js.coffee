jQuery ->
  $("i.like").click ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/iterated_function_systems/#{ifs_id}/like"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
    $.ajax {dataType, url, type, success: success}
  $("i.dislike").click ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/iterated_function_systems/#{ifs_id}/like?negative=1"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
    $.ajax {dataType, url, type, success: success}
