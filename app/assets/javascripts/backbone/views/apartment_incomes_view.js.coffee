# Our overall **AppView** is the top-level piece of UI.
class TodoApp.ApartmentIncomesView extends Backbone.View

  # Instead of generating a new element, bind to the existing skeleton of
  # the App already present in the HTML.
	el: "#todoapp" # WHAT WILL THIS BE FOR ME?

  # Our template for the line of statistics at the bottom of the app.
  # statsTemplate: TodoApp.template '#stats-template'

  # Delegated events for creating new items, and clearing completed ones.
	events:
		"click a.add-apartment-income"  : "createOnClick"
    # "keyup #new-todo"     : "showTooltip"
    # "click .todo-clear a" : "clearCompleted"

  # At initialization we bind to the relevant events on the `Todos`
  # collection, when items are added or changed. Kick things off by
  # loading any preexisting todos that might be saved
	initialize: ->
		_.bindAll this, 'addOne', 'addAll' #, 'renderStats'
		@selectBedrooms = @$('tr#new-apartment-income select')
		@inputUnits = @$('tr#new-apartment-income input.apartment-unit-count')
		@inputSquareFeet = @$('tr#new-apartment-income input.apartment-square-feet')
		@inputMonthlyRent = @$('tr#new-apartment-income input.apartment-monthly-rent')
		
		@collection.bind 'add', @addOne
		@collection.bind 'refresh', @addAll # maybe reset instead?
		@collection.fetch()

  # Re-rendering the App just means refreshing the statistics -- the rest
  # of the app doesn't change.
  # renderStats: ->
  #   @$('#todo-stats').html @statsTemplate
  #     total:      @collection.length
  #     done:       @collection.done().length
  #     remaining:  @collection.remaining().length

  # Add a single todo item to the list by creating a view for it, and
  # appending its element to the `<ul>`.
	addOne: (aptIncSrc) ->
		console?.log "ApartmentIncomesView addOne"
		view = new TodoApp.ApartmentIncomeView model: aptIncSrc
		@$("table#apartment-income tr:last").after view.render().el

  # Add all items in the collection at once.
	addAll: ->
		@collection.each @addOne

  # Generate the attributes for a new Todo item.
	newAttributes: ->
		bedrooms:      parseInt @selectBedrooms.val()
		monthlyRent:   parseInt @inputMonthlyRent.val()
		units:         parseInt @inputUnits.val()
		squareFeet:    sf if (sf = parseInt @inputSquareFeet.val()) is not NaN

  # If you hit return in the main input field, create new **Todo** model,
  # persisting it to server.
	# createOnEnter: ->
	# 	@collection.create @newAttributes()
	# 	@input.val '' # need to get

	createOnClick: ->
		console.log "createOnClick"
		# console.log "newAttributes is #{@newAttributes()}"
		@collection.create @newAttributes()
		@selectBedrooms.val '0'
		@inputUnits.val ''
		@inputSquareFeet.val ''
		@inputMonthlyRent.val ''

  # Clear all done todo items, destroying their views and models.
  # clearCompleted: ->
  #   todo.destroy() for todo in @collection.done()
  #   false

  # Lazily show the tooltip that tells you to press `enter` to save
  # a new todo item, after one second.
  # showTooltip: (e) ->
  #   tooltip = @$(".ui-tooltip-top")
  #   val = @input.val()
  #   tooltip.fadeOut()
  #   clearTimeout @tooltipTimeout if @tooltipTimeout
  #   unless val == '' or val == @input.attr 'placeholder'
  #     @tooltipTimeout = _.delay ->
  #       tooltip.show().fadeIn()
  #     , 1000

class TodoApp.ParkingIncomesView extends Backbone.View

	el: "#todoapp"

	initialize: ->
		_.bindAll this, 'addOne', 'addAll' #, 'renderStats'
		@collection.bind 'add', @addOne
		@collection.bind 'refresh', @addAll # maybe reset instead?
		@collection.fetch()
	
	addAll: ->
		@collection.each @addOne
	
	spacesInput: -> throw new Error('ParkingIncomesView is an abstract class')
	
	monthlyFeeInput: -> throw new Error('ParkingIncomesView is an abstract class')
	
	outdoorOrIndoorSelector: -> throw new Error('ParkingIncomesView is an abstract class')
	
	squareFeetInput: -> throw new Error('ParkingIncomesView is an abstract class')
			
  # Generate the attributes for a new Todo item.
	newAttributes: ->
		sf = parseInt @squareFeetInput().val()
		console?.log "newAttributes, where square feet is #{sf}"
		spaces:           parseInt @spacesInput().val()
		monthlyFee:       parseInt @monthlyFeeInput().val()
		outdoorOrIndoor:  @outdoorOrIndoorSelector().val()
		squareFeet:       sf unless isNaN(sf)

  # If you hit return in the main input field, create new **Todo** model,
  # persisting it to server.
	# createOnEnter: ->
	# 	@collection.create @newAttributes()
	# 	@input.val '' # need to get

	createOnClick: ->
		# console.log "CommercialParkingIncomeView createOnClick"
		# console.log "newAttributes square feet is #{@newAttributes().squareFeet}"
		@collection.create @newAttributes()
		@outdoorOrIndoorSelector().val 'indoor'
		@spacesInput().val ''
		@squareFeetInput().val ''
		@monthlyFeeInput().val ''

class TodoApp.CommercialParkingIncomesView extends TodoApp.ParkingIncomesView

	events:
		"click a.add-commercial-parking-income"  : "createOnClick"
    # "keyup #new-todo"     : "showTooltip"

	initialize: ->
		@selectIndoorOrOutdoor = @$('tr#new-commercial-parking-income select')
		@inputSpaces = @$('tr#new-commercial-parking-income input.commercial-parking-spaces')
		@inputSquareFeet = @$('tr#new-commercial-parking-income input.commercial-parking-square-feet')
		@inputMonthlyFee = @$('tr#new-commercial-parking-income input.commercial-parking-monthly-fee')
		super
	
		
	spacesInput: -> @inputSpaces

	monthlyFeeInput: -> @inputMonthlyFee

	outdoorOrIndoorSelector: -> @selectIndoorOrOutdoor

	squareFeetInput: -> @inputSquareFeet

	addOne: (pkingIncSrc) ->
		console?.log "CommercialParkingIncomesView addOne"
		view = new TodoApp.CommercialParkingIncomeView model: pkingIncSrc
		@$("table#commercial-parking-income tr:last").after view.render().el
	
class TodoApp.ResidentialParkingIncomesView extends TodoApp.ParkingIncomesView

	events:
		"click a.add-residential-parking-income"  : "createOnClick"
    # "keyup #new-todo"     : "showTooltip"

	initialize: ->
		@selectIndoorOrOutdoor = @$('tr#new-residential-parking-income select')
		@inputSpaces = @$('tr#new-residential-parking-income input.residential-parking-spaces')
		@inputSquareFeet = @$('tr#new-residential-parking-income input.residential-parking-square-feet')
		@inputMonthlyFee = @$('tr#new-residential-parking-income input.residential-parking-monthly-fee')
		super
	
	spacesInput: -> @inputSpaces

	monthlyFeeInput: -> @inputMonthlyFee

	outdoorOrIndoorSelector: -> @selectIndoorOrOutdoor

	squareFeetInput: -> @inputSquareFeet

	addOne: (pkingIncSrc) ->
		console?.log "ResidentialParkingIncomesView addOne"
		view = new TodoApp.ResidentialParkingIncomeView model: pkingIncSrc
		@$("table#residential-parking-income tr:last").after view.render().el
	
class TodoApp.SimpleIncomesView extends Backbone.View

	el: "#todoapp"

	initialize: ->
		# _.bindAll this, 'addOne', 'addAll' #, 'renderStats'
		@collection.bind 'add', @addOne
		@collection.bind 'refresh', @addAll # maybe reset instead?
		@collection.fetch()
	
	addAll: =>
		@collection.each @addOne
	
	addOne: (src) => throw new Error('SimpleIncomesView is an abstract class')
	
	usageInput: -> throw new Error('SimpleIncomesView is an abstract class')
	
	monthlyRentInput: -> throw new Error('SimpleIncomesView is an abstract class')
	
	squareFeetInput: -> throw new Error('SimpleIncomesView is an abstract class')
		
	# Generate the attributes for a new Todo item.
	newAttributes: ->
		sf = parseInt @squareFeetInput().val()
		# console?.log "newAttributes, where square feet is #{sf}"
		usage:            @usageInput().val()
		monthlyRent:      parseInt @monthlyRentInput().val()
		squareFeet:       sf unless isNaN(sf)
	
	createOnClick: ->
		# console.log "CommercialParkingIncomeView createOnClick"
		# console.log "newAttributes square feet is #{@newAttributes().squareFeet}"
		@collection.create @newAttributes()
		@usageInput().val ''
		@squareFeetInput().val ''
		@monthlyRentInput().val ''
	

class TodoApp.OtherResidentialIncomesView extends TodoApp.SimpleIncomesView

	events:
		"click a.add-other-income"  : "createOnClick"
    # "keyup #new-todo"     : "showTooltip"

	initialize: ->
		@inputUsage = @$('tr#new-other-income input.other-residential-use')
		@inputSquareFeet = @$('tr#new-other-income input.other-residential-square-feet')
		@inputMonthlyRent = @$('tr#new-other-income input.other-residential-monthly-rent')
		super
	
	usageInput: -> @inputUsage

	monthlyRentInput: -> @inputMonthlyRent

	squareFeetInput: -> @inputSquareFeet

	addOne: (incSrc) =>
		# console?.log "CommercialParkingIncomesView addOne"
		view = new TodoApp.OtherResidentialIncomeView model: incSrc
		@$("table#other-residential-income tr:last").after view.render().el
	

class TodoApp.CommercialIncomesView extends TodoApp.SimpleIncomesView

	events:
		"click a.add-commercial-income"  : "createOnClick"
			
	initialize: ->
		@inputUsage = @$('tr#new-commercial-income input.commercial-use')
		@inputSquareFeet = @$('tr#new-commercial-income input.commercial-square-feet')
		@inputMonthlyRent = @$('tr#new-commercial-income input.commercial-monthly-rent')
		super
	
	usageInput: -> @inputUsage

	monthlyRentInput: -> @inputMonthlyRent

	squareFeetInput: -> @inputSquareFeet

	addOne: (incSrc) ->
		# console?.log "CommercialParkingIncomesView addOne"
		view = new TodoApp.CommercialIncomeView model: incSrc
		@$("table#commercial-income tr:last").after view.render().el
	
