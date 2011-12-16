describe "LoanCriteria", ->
	server = null
	criteria = null
	options = null
	valid = null
	
	beforeEach ->
		data = {someElement: "something", anotherElement: "another item"}
		options = {data: data}
		criteria = new TodoApp.LoanCriteria
		server = sinon.fakeServer.create()
		valid =
			"status": "OK"
			"version": "1.0"
			"response":
				"criteria": [
					{
						"criterion": 3,
						"loanAmount": 4000000
					},
					{
						"criterion": 4,
						"loanAmount": 2000000
					},
					{
						"criterion": 5,
						"loanAmount": 6000000
					},
					{
						"criterion": 7,
						"loanAmount": 5000000
					}
				]
	
	afterEach ->
		server.restore()
	
	describe "comparator", ->
		it "should place criteria in ascending order of loan amount after refresh", ->
			criteria.refresh valid.response.criteria
			expect(criteria.at(0).get('criterion')).toEqual 4
			expect(criteria.at(1).get('criterion')).toEqual 3
			expect(criteria.at(2).get('criterion')).toEqual 7
			expect(criteria.at(3).get('criterion')).toEqual 5
		
	describe "loanAmount", ->
		it "should be the first criteria loan amount", ->
			criteria.refresh valid.response.criteria
			expect(criteria.loanAmount()).toEqual criteria.at(0).get('loanAmount')
		
		it "should be undefined when no criterion members present", ->
			expect(criteria.isEmpty()).toBe true
			expect(criteria.loanAmount()).toBe undefined
	
	describe "loanCriterion", ->
		it "should be the first criterion", ->
			criteria.refresh valid.response.criteria
			expect(criteria.limitingCriterion()).toEqual criteria.at(0).get('criterion')

		it "should be undefined when no criterion members present", ->
			expect(criteria.isEmpty()).toBe true
			expect(criteria.limitingCriterion()).toBe undefined
	
	describe "request when Backbone.emulateJSON is (default) false", ->
			
		it "should be as expected", ->
			criteria.fetch(options)
			expect(server.requests.length).toEqual 1
			expect(server.requests[0].method).toEqual "GET"
			expectedRequest = "/sec223f_acquisition_loan?someElement=something&anotherElement=another+item"
			expect(server.requests[0].url).toEqual expectedRequest
			expect(server.requests[0].async).toEqual true
		
	describe "request when Backbone.emulateJSON is set to true", ->	
		it "should modify request content type header", ->
			Backbone.emulateJSON = true
			criteria.fetch(options)
			expect(server.requests.length).toEqual 1
			expect(server.requests[0].requestHeaders['Content-Type']).toEqual 'application/x-www-form-urlencoded'
			Backbone.emulateJSON = false
		
	
	
	describe "parse", ->
		it "should convert the response into the expected array", ->
			result = criteria.parse valid
			expect(result).toEqual valid.response.criteria
	
	describe "success response handling", ->
		
		beforeEach ->
			server.respondWith(
				[200,
				{"Content-Type": "application/json"},
				JSON.stringify(valid)
				]
				)
		
		it "should create 4 criterion objects", ->
			criteria.fetch(options)
			server.respond()
			expect(criteria.length).toEqual 4
			criteria.each (crit) ->
				expect(crit instanceof TodoApp.LoanCriterion).toBe true
			
		
		it "should call success function, when given", ->
			callback = sinon.spy()
			options.success = callback
			criteria.fetch(options)
			server.respond()
			expect(callback.calledOnce).toBeTruthy()
	
	describe "error response handling", ->

		beforeEach ->
			server.respondWith(
				[400,
				{"Content-Type": "application/json"},
				'{"something": 200}'
				]
				)	
		
		it "should trigger error on criteria when no callback given", ->
			eventSpy = sinon.spy()
			criteria.bind("error", eventSpy)
			criteria.fetch(options)
			server.respond()
			expect(eventSpy.calledOnce).toBeTruthy()
		
		it "should call error function, when given", ->
			callback = sinon.spy()
			options.error = callback
			criteria.fetch(options)
			server.respond()
			expect(callback.calledOnce).toBeTruthy()
		