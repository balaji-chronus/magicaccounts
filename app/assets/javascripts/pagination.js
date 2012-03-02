$(function() {
  $(".pagination span.not('.page.current') a").live("click", function() {
    $(".pagination").html("Loading Transactions...");
    $.post($(this).attr("action"),  $(this).serialize(), null, "script");
    return false;
  });
});

// For older jQuery versions...
jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});