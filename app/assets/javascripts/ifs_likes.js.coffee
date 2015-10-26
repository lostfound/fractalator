jQuery ->
  $('body').off 'click', 'a.like'
  $('body').on 'click', 'a.like', ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/fractals/#{ifs_id}/like"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
      ifs_node.find(".score_currency").removeClass "fa-frown-o"
      ifs_node.find(".score_currency").addClass "fa-smile-o"
      ifs_node.find(".like, .dislike").remove()
    $.ajax {dataType, url, type, success: success}
    false
  $('body').off 'click', 'a.dislike'
  $('body').on 'click', 'a.dislike', ->
    ifs_id = parseInt $(@).parents(".ifs").attr "data-id"
    dataType='json'
    url="/fractals/#{ifs_id}/like?negative=1"
    type="GET"
    success= (son)=>
      ifs_node= $(".ifs[data-id=#{son.id}]")
      ifs_node.find(".score").html "#{son.score}"
      ifs_node.find(".score_currency").removeClass "fa-smile-o"
      ifs_node.find(".score_currency").addClass "fa-frown-o"
      ifs_node.find(".like, .dislike").remove()
    $.ajax {dataType, url, type, success: success}
    false
