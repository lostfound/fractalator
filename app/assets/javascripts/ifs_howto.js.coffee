jQuery ->
  $("a span.label").click ->
    hr = $(@).parent().attr 'href'
    panel = $(hr)
    $(".panel:not(#{hr})").addClass "hide"
    panel.toggleClass "hide"
    false
