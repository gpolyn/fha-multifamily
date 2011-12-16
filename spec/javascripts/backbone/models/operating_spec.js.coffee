describe "Operating", ->
	operating = null
	operatingIncome = null
	operatingExpense = null
	
	beforeEach ->
		operatingIncome = new Backbone.Model
		operatingExpense = new Backbone.Model
	
	describe "toJSON", ->
		operatingIncome = new Backbone.Model
		operatingExpense = new Backbone.Model
		expectedOperatingIncomeHash = 
			something:     "la"
			somethingElse: "di"
		operatingIncome.toJSON = -> expectedOperatingIncomeHash
		expectedOpexHash = _.extend expectedOperatingIncomeHash, {anotherThing: "da"}
		operatingExpense.toJSONWithoutIDParam = -> expectedOpexHash
		expectedSpaceHash = _.extend expectedOperatingIncomeHash, {yetAnotherThing: "dog!"}
		operatingIncome.spaceUtilizationHash = -> expectedSpaceHash
		expectedHash = 
			operatingExpense: expectedOpexHash
			operatingIncome:  expectedOperatingIncomeHash
			spaceUtilization: expectedSpaceHash
		attrs = {operatingIncome: operatingIncome, operatingExpense: operatingExpense, id: 1232312}
		operating = new TodoApp.Operating attrs
		expect(operating.toJSON()).toEqual expectedHash
	
	describe "netOperatingIncome", ->
		
		describe "when opex total and egi are both available", ->
			expected = null
			
			beforeEach ->
				operatingIncome.effectiveGrossIncome = -> 2000
				operatingExpense.set {total: 45.2}, {silent: true}
		
			afterEach ->
				attrs = {operatingIncome: operatingIncome, operatingExpense: operatingExpense}
				operating = new TodoApp.Operating attrs
				expect(operating.netOperatingIncome()).toBeCloseTo expected, 0.005
		
			it "should be the difference between opex total in % terms and egi", ->
				operatingExpense.set {totalIsPercentOfEffectiveGrossIncome: true}, {silent: true}
				expected = operatingExpense.get('total')/100 * operatingIncome.effectiveGrossIncome()
		
			it "should be the difference between opex total in absolute terms and egi", ->
				operatingExpense.set {totalIsPercentOfEffectiveGrossIncome: false}, {silent: true}
				# operatingExpense.totalIsPercentOfEffectiveGrossIncome = -> false
				expected = operatingIncome.effectiveGrossIncome() - operatingExpense.get('total')
			
		describe "when one of egi or opex total is unavailable", ->
			beforeEach ->
				operatingExpense.totalIsPercentOfEffectiveGrossIncome = -> false
				
			afterEach ->
				attrs = {operatingIncome: operatingIncome, operatingExpense: operatingExpense}
				operating = new TodoApp.Operating attrs
				expect(operating.netOperatingIncome()).toBe undefined
			
			it "should be undefined when egi is null", ->
				operatingIncome.effectiveGrossIncome = -> null
				operatingExpense.total = -> 45.2
			
			it "should be undefined when total expenses is undefined", ->
				operatingIncome.effectiveGrossIncome = -> 2000
				operatingExpense.total = -> # intentional no-op
			
	describe "resizeLoan event", ->
		eventSpy = null
		
		beforeEach ->
			eventSpy = sinon.spy()
			attrs = {operatingIncome: operatingIncome, operatingExpense: operatingExpense}
			operating = new TodoApp.Operating attrs
			operating.bind("resizeLoan", eventSpy)
		
		afterEach ->
			expect(eventSpy.calledOnce).toBeTruthy()
			
		it "should be triggered when operatingExpense has a change event", ->
			operating.get('operatingExpense').trigger "change"
		
		it "should be triggered when operatingIncome has a resizeLoan event", ->
			operating.get('operatingIncome').trigger "resizeLoan"
	