describe "Affordability", ->
	affordability = null
	
	beforeEach ->
		affordability = new TodoApp.Affordability
		
	describe "inheritance from TodoApp.SingletonLikeModel", ->

		it "should be an instance of TodoApp.SingletonLikeModel", ->
			expect(affordability instanceof TodoApp.SingletonLikeModel).toBe true

		it "should implement abstract localStorage class method", ->
			expect(TodoApp.Affordability.localStorage() instanceof Store).toBe true
			expect(TodoApp.Affordability.localStorage().name).toEqual "affordability"
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(affordability.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'affordability'", ->
			expect(affordability.localStorage.name).toEqual 'affordability'
	

	describe "validation", ->
		describe "level", ->
			it "must be one of 'market', 'affordable' or 'subsidized'", ->
				eventSpy = sinon.spy()
				affordability.bind("error", eventSpy)
				errorMsg = "Affordability must be one of 'market', 'affordable' or 'subsidized'"
				affordability.set {level: "toothy"}
				expect(eventSpy.calledOnce).toBeTruthy()
				expect(eventSpy.calledWith(affordability, [errorMsg])).toBeTruthy()
			
	
	describe "toJSON", ->
		it "should be the expected hash", ->
			attrs = {id: 12321312}
			expected = {level: "subsidized"}
			_.extend attrs, expected
			affordability.set attrs
			expect(affordability.toJSON()).toEqual expected
		