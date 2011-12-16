class TodoApp.MetropolitanAreaView extends Backbone.View
	
	tagName: "div"
	
	id: "metropolitan-area"
	
	template: TodoApp.template '#metropolitan-area-template'
	
	events:
		"change select"  : "save"
	
	initialize: ->
		@model.set({value: "no waiver"}, {silent: true}) if @model.isNew()
		@model.bind 'change', @render
		$("#income").append(@render().el)
	
	render: =>
		$(@el).html @template {list: TodoApp.MetropolitanArea.list()}
		@setContent()
		@
	
	setContent: ->
		@$("#high-cost-setting option[value='" + @model.get('value') + "']").attr('selected', 'selected')
	
	save: ->
		@model.save {value: @$("#high-cost-setting").val()}
	