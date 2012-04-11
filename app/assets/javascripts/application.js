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


jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

var Transaction = {
        setTransactionUserAmount: function(){
          var amount = jQuery('#transaction_equal_amount').val() ? jQuery('#transaction_equal_amount').val() : 0;
          var active_users = jQuery(".txnamountuser.active");
          if(active_users)
            active_users.siblings(".txnuseramount").val(amount/active_users.length);
        },
        setActiveTransactionUsers: function(e){
          jQuery(e).siblings(".txnuserdestroy").val(!(jQuery(e).hasClass("active")));
        },
        cleanUpTransactionUsers: function(){
            jQuery('.txnuserdestroy').val(true);
            jQuery('.txnamountuser').removeClass("active")
            jQuery('.txnuseramount').val("");
        },
        setUpTransactionUsers: function(e){
            var user = jQuery(e).val();
            if(user)
                jQuery("input.txn_user_amt_id[value='" + user + "']").siblings(".txnamountuser").addClass("active").siblings(".txnuseramount").val(jQuery("#transaction_equal_amount").val()).siblings(".txnuserdestroy").val(false);
        },
        calculateAmount: function() {
            var amount = 0;
            jQuery(".txnuseramount").each(function() {
                if(!isNaN(this.value) && this.value.length!=0) {
                    amount += parseFloat(this.value);
                }
            });
            return amount.toFixed(2);
        }
    }    

    jQuery(document).ready(function() {
        jQuery.fn.submitWithAjax = function() {
        this.submit(function() {
            jQuery.post(this.action, jQuery(this).serialize(), null, "script");
            return false;
        })
        return this;
    };
    
    jQuery("#new_transaction").submit(function() {
        if(Transaction.calculateAmount() <=0)
        {
            alert("Choose atleast one beneficiary with amount greater than 0");
            return false;
        }
        jQuery.post(this.action, jQuery(this).serialize(), null, "script");
        return false;
    });

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
   

   jQuery('.txnamountuser').live("click", function(){
        jQuery(this).toggleClass("active");
        Transaction.setActiveTransactionUsers(this);
        Transaction.setTransactionUserAmount();
    });

   jQuery("#transaction_equal_amount").live("blur", function(){
        Transaction.setTransactionUserAmount();
   });

   jQuery(".prepended_amount_input").live("blur", function(){
        var amount = jQuery(this).val();        
        if(amount && amount > 0 )
            jQuery(this).addClass("active");
        else
            jQuery(this).removeClass("active");        
        Transaction.setActiveTransactionUsers(this);
   });

   jQuery('#transaction_user_id').change(function(){       
       Transaction.cleanUpTransactionUsers();
       Transaction.setUpTransactionUsers(this);
   });
   
})

