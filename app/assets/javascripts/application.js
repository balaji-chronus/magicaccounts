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
    jQuery.post(this.action, jQuery(this).serialize(), null, "script");
    return false;
    })
    return this;
   };
    
   jQuery("#new_transaction").submitWithAjax();
   jQuery("#form_invite").submitWithAjax();

   jQuery("#newtranbtn").live("click", function() {
     jQuery('#newacctran').slideToggle(2000);
     jQuery(this).text(jQuery(this).text() == 'Move up' ? 'New Transaction' : 'Move up');
   });
       
   jQuery('#hidetranbtn').click(function(){
     jQuery('#newacctran').hide("blind", {direction : "vertical"}, 2000);
        jQuery("#newtranbtn").text(jQuery("#newtranbtn").text() == 'Move up' ? 'New Transaction' : 'Move up');
   });

   // Transaction Form
   var Transaction = {
        setTransactionUserAmount: function(){          
          var amount = jQuery('#transaction_equal_amount').val() ? jQuery('#transaction_equal_amount').val() : 0;
          var active_users = jQuery(".txnamountuser.active");          
          active_users.siblings(".txnuseramount").val(amount/active_users.length);
        },
        setActiveTransactionUsers: function(e){            
            jQuery(e).siblings(".txnuserdestroy").val(!(jQuery(e).hasClass("active")));
        }
    }

   jQuery('.txnamountuser').click(function(){
        jQuery(this).toggleClass("active");
        Transaction.setActiveTransactionUsers(this);
        Transaction.setTransactionUserAmount();
    });

   jQuery("#transaction_equal_amount").blur(function(){
        Transaction.setTransactionUserAmount();
   });

   jQuery(".prepended_amount_input").blur(function(){
        var amount = jQuery(this).val();
        if(amount && amount > 0 )        
            jQuery(this).addClass("active");
        else
            jQuery(this).removeClass("active");        
        Transaction.setActiveTransactionUsers(this);
   });
})

