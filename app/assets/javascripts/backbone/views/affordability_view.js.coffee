class TodoApp.AffordabilityView extends Backbone.View
	
	tagName: "div"
	
	id: "affordability"
	
	template: TodoApp.template '#affordability-template'
	
	events:
		"change input"  : "save"
	
	initialize: ->
		console?.log "Affordability initialize..."
		console?.log "model attributes are #{JSON.stringify @model.attributes}"
		@model.set({level: "market"}, {silent: true}) if @model.isNew()
		@model.bind 'change', @render
		$("#income").append(@render().el)
	
	render: =>
		$(@el).html @template #@model.toJSON()
		@setContent()
		# console?.log "just got back to render from setContent"
		@
	
	save: ->
		console?.log "AffordabilityView testing"
		@model.save @readAttributes()
	
	setContent: ->
		@$("input#" + @model.get 'level').attr('checked', true)
	
	readAttributes: ->
		{level: @$('input[name=affordability]:checked', '#affordability').val()}
	