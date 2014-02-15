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

var Group = {
        autocomplete: function(path,id,placeholder) {
           function format(email) {
// optgroup
    return get_avatar(email.avatar) + " " + email.text;
    }
          $(id).select2({
             formatResult: format,
    formatSelection: format,
    escapeMarkup: function(m) { return m; },
             
            placeholder: placeholder,
            allowClear: true,
            width: '100%',
          
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
  
  function get_avatar(avatar_id) {
    return "<img src = 'http://gravatar.com/avatar/" + avatar_id + ".png' height = '32' />" ;
    }



  
   


        }
      }

var Transaction = {
        setTransactionUserAmount: function(){
          var transaction_type = jQuery("#mg-transaction-type li.active").attr("transaction-type");
          
          if(transaction_type == "1") {
            Transaction.splitEqually();
            Transaction.setEqualAmount();
            jQuery("#mgexpensebeneficiary .toggle-on").text("Split Equally");
          }
          else if(transaction_type == "2") {
            Transaction.splitUnEqually();
            Transaction.setAmountLeft();
            jQuery("#mgexpensebeneficiary .toggle-on").text("Split by Exact Amount");
          }
          else if(transaction_type == "3") {
            jQuery("#mgexpensebeneficiary .toggle-on").text("Personal Expense");
          }
        },
        splitEqually: function(e){
          jQuery("#mg-split-equally .list-group-item").each(function(i){
            var element = jQuery(this).children(".col-xs-2").children(".icon-stack").first();
            var user_id = jQuery(this).attr("user_id");

            if(element.hasClass("hidden")) {
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(true);
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val("");
            }
            else {
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(false);
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val(Transaction.splitAmount());
            }
          })
        },
        setEqualAmount: function(){
          jQuery("#mg-split-equally .list-group-item .col-xs-4 span").text("0.00");
          jQuery("#mg-split-equally .list-group-item .col-xs-2").children(".icon-stack:not(.hidden)").each(function(i){
            jQuery(this).parent().siblings('.col-xs-4').children('span').text(Transaction.splitAmount());
          });
        },
        splitUnEqually: function(e){
          jQuery("#mg-split-unequally .list-group-item").each(function(i){
            var user_id = jQuery(this).attr("user_id");
            var amount = jQuery(this).children(".mg-exact-user-amount").children("input").first().val();
            var exact_amount = parseFloat(amount);
            exact_amount = isNaN(exact_amount) || exact_amount < 0 ? 0.00 : exact_amount;

            if(exact_amount == 0.00) {
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(true);
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val("");
            }
            else {
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(false);
              jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val(amount);
            }
          });
        },
        setAmountLeft: function(){
          var exact_amount_sum = 0.00;
          jQuery("#mg-split-unequally .list-group-item .mg-exact-user-amount input").each(function(){
            var exact_amount = parseFloat(jQuery(this).val());
            exact_amount = isNaN(exact_amount) || exact_amount < 0 ? 0.00 : exact_amount;
            exact_amount_sum += exact_amount;
          });
          jQuery('#mg-amount-left').text((Transaction.getExpenseAmount() - exact_amount_sum).toFixed(2));
        },
        setPersonalTransaction: function(){
          Transaction.cleanUpTransactionUsers();
            
        },
        cleanUpTransactionUsers: function(){
            jQuery('.mg-txn-user-destroy').val(true);
            jQuery('.mg-txn-user-amount').val("");
        },
        splitAmount: function() {
          var amount = Transaction.getExpenseAmount();
          var benefactors = jQuery("#mg-split-equally .list-group-item .col-xs-2 .icon-stack:not(.hidden)").length;
          return (amount/benefactors).toFixed(2);
        },
        getExpenseAmount: function(){
          var amount = parseFloat(jQuery("#transaction_amount").val());
          if(isNaN(amount))
            amount = 0.00;
          return amount;
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



