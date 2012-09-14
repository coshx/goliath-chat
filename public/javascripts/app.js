$(document).ready(function() {
  var source = new EventSource('/chat');

  source.addEventListener('open', function(e) {
    console.log('connection opened');
  }, false);

  source.onmessage = function(e) {
    message = $.parseJSON(e.data);
    showMessage(message);
  };

  source.addEventListener('error', function(e) {
    if (e.eventPhase == EventSource.CLOSED) {
      console.log('connection closed');
    }
  }, false);

  $("input#message").keypress(function(event) {
    if (event.keyCode == 13) {
      // user pressed enter within message input
      sendMessage($(this).val());
      $(this).val("");
    }
  });
});

function showMessage(message) {
  console.log("Read: "+message);
  $("ul#message-list").prepend("<li>"+message+"</li>");
}

function sendMessage(message) {
  console.log("Write: "+message);
  $.post(
    "/chat", { msg : message }
  );
}
