describe "LoanService", ->
	loanService = null
	operating = null
	affordability = null
	metropolitanArea = null
	loanCosts = null
	criteria = null
	attributes = null
	
	beforeEach ->
		criteria = new Backbone.Collection
		criteria.fetch = (options) -> # no-op
		operating = new Backbone.Model
		affordability = new Backbone.Model
		metropolitanArea = new Backbone.Model
		loanCosts = new Backbone.Model
		attributes =
			criteria:         criteria
			operating:        operating
			affordability:    affordability
			metropolitanArea: metropolitanArea
			loanCosts:        loanCosts
		# loanService = new TodoApp.LoanService attributes
	
	describe "unsupported operations", ->
		beforeEach ->
			loanService = new TodoApp.LoanService attributes
		
		expectedErrorMsg = "Persistence-related actions not available in this class"
		
		it "should throw an error with expected msg. when fetch called", ->
			expect(do -> loanService.fetch).toThrow expectedErrorMsg
		
		it "should throw an error with expected msg. when save called", ->
			expect(do -> loanService.save).toThrow expectedErrorMsg
		
		it "should throw an error with expected msg. when destroy called", ->
			expect(do -> loanService.destroy).toThrow expectedErrorMsg
		
	describe "fetch being called on criteria", ->
		spy = null
		
		beforeEach ->
			spy = sinon.spy criteria, 'fetch'
			loanService = new TodoApp.LoanService attributes
			
		
		afterEach ->
			expect(spy.calledOnce).toBe true
			criteria.fetch.restore()
			
		it "should be called when operating member has a resizeLoan event", ->
			operating.trigger "resizeLoan"
		
		it "should be called when affordability member has a change event", ->
			affordability.trigger "change"
		
		it "should be called when metropolitanArea member has a change event", ->
			metropolitanArea.trigger "change"
		
		it "should be called when loanCosts member has a resizeLoan event", ->
			loanCosts.trigger "resizeLoan"
	
	describe "toJSON", ->
		expectedOperating = {something: 123}
		expectedAffordability = {somethingElse: "gyut"}
		expectedMetroArea = {yetAnotherThing: 234}
		expectedLoanCosts = {lastThingMaybe: "yuyuy"}
		expected = null
		
		beforeEach ->
			operating.toJSON = -> expectedOperating
			affordability.toJSON = -> expectedAffordability
			metropolitanArea.toJSON = -> expectedMetroArea
			loanCosts.toJSON = -> expectedLoanCosts
			attributes =
				criteria:         criteria
				operating:        operating
				affordability:    affordability
				metropolitanArea: metropolitanArea
				loanCosts:        loanCosts
			loanService = new TodoApp.LoanService attributes
			expected = 
				operating:        operating.toJSON()
				affordability:    affordability.toJSON()
				metropolitanArea: metropolitanArea.toJSON()
				loanCosts:        loanCosts.toJSON()

		afterEach ->
			expect(loanService.toJSON()).toEqual expected
		
		it "should have the initial settings of the members after instantiation", ->
		
		it "should update after operating changes", ->
			newOperatingAttrs = {someOtherAttr: "something"}
			operating.toJSON = -> newOperatingAttrs
			operating.trigger "resizeLoan"
			expected.operating = newOperatingAttrs
		
		it "should update after affordability changes", ->
			newAffordabilityAttrs = {someOtherAttr: "something new"}
			affordability.toJSON = -> newAffordabilityAttrs
			affordability.trigger "change"
			expected.affordability = newAffordabilityAttrs
	
		it "should update after metropolitanArea changes", ->
			newMetroAreaAttrs = {someOtherAttr: "something new"}
			metropolitanArea.toJSON = -> newMetroAreaAttrs
			metropolitanArea.trigger "change"
			expected.metropolitanArea = newMetroAreaAttrs
	
		it "should update after loanCosts changes", ->
			newLoanCostAttrs = {someOtherAttr: "something new"}
			loanCosts.toJSON = -> newLoanCostAttrs
			loanCosts.trigger "resizeLoan"
			expected.loanCosts = newLoanCostAttrs	