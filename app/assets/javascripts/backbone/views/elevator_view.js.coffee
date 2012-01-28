class TodoApp.ElevatorStatusView extends Backbone.View
	
	tagName: "div"
	
	id: "elevator-status"

	template: _.template "project has elevator?<select id='elevator-status'><option value=false>false</option><option value=true>true</option></select>"
	
	events:
		"change select"  : "save"
	
	initialize: ->
		$("#income").append(@render().el)
	
	render: ->
		$(@el).html @template
		@setContent()
		@
	
	setContent: ->
		hasElevator = @model.get 'hasElevator'
		@selectElevatorStatus = @$('select#elevator-status')
		@selectElevatorStatus.val "" + hasElevator
		
	save: ->
		@model.save @readAttributes(), {error: => @render()}
	
	readAttributes: ->
		hasElevator: @selectElevatorStatus.val() is 'true'
	