# This file, named "a", is just a contrivance to ensure the methods contained herein are loaded,
# pending my introduction of something like require.js.

TodoApp.getNullOrVal = (cssSelectorStr) ->
	if (val = jQuery.trim($(cssSelectorStr).val())) is "" then null else val

TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments