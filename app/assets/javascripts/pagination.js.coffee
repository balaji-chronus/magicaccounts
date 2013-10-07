jQuery ->
  if jQuery('.pagination').length
    jQuery(window).scroll ->
      url = jQuery('.pagination .next_page').attr('href')
      if url && jQuery(window).scrollTop() > jQuery(document).height() - jQuery(window).height() - 50
        jQuery('.pagination').text("Fetching more results ...")
        jQuery.getScript(url)
    $(window).scroll()