jQuery ->
  $("a span.label").click ->
    hr = $(@).parent().attr 'href'
    panel = $(hr)
    if panel.hasClass "hide"
      panel.removeClass "hide"
    else
      panel.addClass("hide")
    false
