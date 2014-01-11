// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require flatly/loader
//= require flatly/bootswatch
//= require rails.validations
//= require select2
//= require pagination
//= require bootstrap-toggle
//= require bootstrap-datepicker

jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

jQuery(document).ajaxSend(function(e, xhr, options) {
  var token = jQuery("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

var Utilities = {
    redirectTo: function(e,path){
        e.preventDefault();
        parent.location = path;
    }
}

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
            jQuery('.prepended_amount_input').val("").removeClass("active");
        },
        setUpTransactionUsers: function(e){
            var user = jQuery(e).val();
            if(user)
                jQuery("input.txn_user_amt_id[value='" + user + "']").siblings(".txnamountuser").addClass("active").siblings(".txnuseramount").val(jQuery("#transaction_equal_amount").val()).siblings(".txnuserdestroy").val(false);
        },
        calculateAmount: function() {
            var amount = 0;
            jQuery(".txnuseramount,.prepended_amount_input").each(function() {
                if(!isNaN(this.value) && this.value.length!=0) {
                    amount += parseFloat(this.value);
                }
            });
            return amount.toFixed(2);
        },

        getUserBalance: function(url, group) {

          if(this.xhr && this.xhr.readyState != 4){
            this.xhr.abort();
          }

          this.xhr = jQuery.ajax ({
              url: url,
              data: jQuery.param({ group_id: group, format: 'js'}),
              type: 'GET'
          });
        },

        autocomplete: function(path, id, selectedData, placeholderText) {
          jQuery(id).select2({
            placeholder: placeholderText,
            dropdownCssClass: "transaction_category_tags",
            multiple: true,
            minimumInputLength: 1,
            tags: [],
            ajax: { 
                url: path,
                data: function (term, page) {
                    return {
                        term: term, // search term
                        page_limit: 10,
                        page: page,
                        selection: jQuery(id).select2("val")
                    };
                },
                results: function (data, page) {
                    var more = (data.length == 10);
                    return {
                        results: data,
                        more: more
                    };
                }
            },
            createSearchChoice:function(term) {
                    return {
                        id:jQuery.trim(term),
                        text:jQuery.trim(term)
                    };
            }
          });
          if(typeof selectedData != 'undefined')
            jQuery(id).select2("data", selectedData);
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

   // Transaction Form   

   jQuery(document).on("click", '.txnamountuser', function(){
        jQuery(this).toggleClass("active");
        Transaction.setActiveTransactionUsers(this);
        Transaction.setTransactionUserAmount();
    });

   jQuery(document).on("blur", "#transaction_equal_amount", function(){
        Transaction.setTransactionUserAmount();
   });

   jQuery(document).on("blur", ".prepended_amount_input", function(){
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


   // Reports Page
   jQuery("#report_date_option").change(function(){
       if(jQuery(this).val() == "Custom Range")
       {
          jQuery('#dynamic_date_range').fadeIn();
       }
       else
       {
          jQuery('#dynamic_date_range').fadeOut();
       }
   });

    // jQuery(".date_select").datepicker({format: 'yyyy-mm-dd'});
})



