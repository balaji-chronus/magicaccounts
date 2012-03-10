// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
////= require jquery.ui.all
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .
//= require rails.validations
//= require rails.validations.custom


jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

$(document).ready(function() {
    
   jQuery.fn.submitWithAjax = function() {
    this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
    })
    return this;
   };
    
   $("#new_transaction").submitWithAjax();
   $("#form_invite").submitWithAjax();

   $("#newtranbtn").live("click", function() {
     $('#newacctran').slideToggle();
     $(this).text($(this).text() == 'Move up' ? 'New Transaction' : 'Move up');
   });
       
   $('#hidetranbtn').click(function(){
     $('#newacctran').hide("blind", {direction : "vertical"}, 350);
        $("#newtranbtn").text($("#newtranbtn").text() == 'Move up' ? 'New Transaction' : 'Move up');
   });

})

