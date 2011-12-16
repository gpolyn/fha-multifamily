# This file, named "a", is just a contrivance to ensure the methods contained herein are loaded,
# pending my introduction of something like require.js.

TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments