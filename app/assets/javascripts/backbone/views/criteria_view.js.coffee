class TodoApp.LoanCriterionView extends Backbone.View
	
	tagName: "div"
	
	className: "loan-criterion"
	
	# id: "metropolitan-area"
	
	# template: TodoApp.template '#metropolitan-area-template'
	
	# events:
		# "change select"  : "save"
	
	initialize: ->
		@template = TodoApp.template @options.templateId
		@id = @options.viewId
		@model.bind 'destroy', => @remove()
		
		# @model.set({value: "no waiver"}, {silent: true}) if @model.isNew()
		# @model.bind 'change', @render
		
		# $("#income").append(@render().el)
	
	render: =>
		$(@el).html @template @model.toJSON()
		@


class TodoApp.CriteriaView extends Backbone.View
	
	el: "#todoapp"
	
	template: TodoApp.template '#criteria-template'
	
	initialize: ->
		@collection.bind 'refresh', @removeCurrent
		@collection.bind 'refresh', @addAll
		@renderConclusions()
		# @collection.fetch()
	
	addOne: (todo) =>
		console?.log "inside addOne"
		view = new TodoApp.LoanCriterionView {model: todo, templateId: "#loan-criterion", viewId: "anyId"}
		@$("#loan-results").append view.render().el

	# Add all items in the collection at once.
	addAll: =>
		console?.log "inside addAll"
		@collection.each @addOne
	
	removeCurrent: =>
		# console?.log "removeCurrent" unless @collection.isEmpty()
	
	renderConclusions: =>
		@$('#loan-results').html @template
			loanAmount:      400000#@collection.length
			cashRequirement: 345#@collection.done().length