jQuery ->
  $("a.like").click ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/iterated_function_systems/#{ifs_id}/like"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
      ifs_node.find(".score_currency").removeClass "fa-frown-o"
      ifs_node.find(".score_currency").addClass "fa-smile-o"
    $.ajax {dataType, url, type, success: success}
    false
  $("a.dislike").click ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/iterated_function_systems/#{ifs_id}/like?negative=1"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
      ifs_node.find(".score_currency").removeClass "fa-smile-o"
      ifs_node.find(".score_currency").addClass "fa-frown-o"
    $.ajax {dataType, url, type, success: success}
    false
