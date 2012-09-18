$(document).ready ->
  unless "WebSocket" of window
    alert "Sorry, WebSockets unavailable."
    return
  ws = new WebSocket("ws://localhost:9000/chat")
  ws.onmessage = (evt) ->
    console.log evt
    $("#msg").prepend "<li>#{evt.data}</li>"

  ws.onclose = ->
    console.log "socket closed"

  ws.onopen = ->
    console.log "connected..."

  $("#submit").click ->
    nick = $("#nick").val()
    msg = $("#message").val()
    ws.send "#{nick}: #{msg}"
    false
