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
//= require_tree ./templates

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
    jQuery(".mg-transaction-total-amount").text(Transaction.getExpenseAmount());
    var transaction_type = jQuery("#mg-transaction-type li.active").attr("transaction-type");
    
    if(transaction_type == "1") {
      Transaction.splitEqually();
      Transaction.setEqualAmount();
    }
    else if(transaction_type == "2") {
      Transaction.splitUnEqually();
      Transaction.setAmountLeft();
      jQuery("#mgexpensebeneficiary .toggle-on").text("Split by Exact Amount").siblings('label').removeClass('toggle-off');;
    }
    else if(transaction_type == "3") {
      Transaction.setPersonalTransaction();
      jQuery("#mgexpensebeneficiary .toggle-on").text("Personal Expense").siblings('label').removeClass('toggle-off');;
    }
    Transaction.setAmountPaid();
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
        jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val("0.00");
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
    var user_id = jQuery("#transaction_user_id").val();
    jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(false);
    jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount").val(Transaction.getExpenseAmount());
  },
  cleanUpTransactionUsers: function(){
      jQuery('.mg-txn-user-destroy').val(true);
      jQuery('.mg-txn-user-amount').val("");
  },
  setAmountPaid: function(){
    var user_id = jQuery("#transaction_user_id").val();
    jQuery('.mg-txn-user-amount-paid').val("0.00");
    jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-destroy").val(false);
    jQuery("#mg-expense-users-" + user_id + " .mg-txn-user-amount-paid").val(Transaction.getExpenseAmount());
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
  toggleModalSwitch: function(toggleId){
    if(jQuery(toggleId).hasClass('off'))
      jQuery(toggleId).click();
    else
      jQuery(jQuery(toggleId).attr('target-element')).modal('show');
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
      dropdownCssClass: "transaction_category_tags list-group",
      multiple: true,
      closeOnSelect: false,
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
      formatResult: Transaction.formatItemResult,
      formatSelection: Transaction.formatItemselection,
      formatResultCssClass: function () { return "list-group-item"; },
      createSearchChoice:function(term) {
        return {
          'id': jQuery.trim(term),
          'text': jQuery.trim(term),
          'icon_class': 'icon-exclamation'
        };
      }
    });
    if(typeof selectedData != 'undefined')
      jQuery(id).select2("data", selectedData);
  },

  formatItemResult: function(item) {
    return JST["templates/category_choice"]({
      item: item
    });
  },

  formatItemselection: function(item) {
    return JST["templates/category_keyword"]({
      item: item
    });
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
      jQuery('#dynamic_date_range').fadeIn();
    else
      jQuery('#dynamic_date_range').fadeOut();
  });

  jQuery('.mg-tooltip').tooltip();
})



