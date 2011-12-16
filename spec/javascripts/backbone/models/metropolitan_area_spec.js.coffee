describe "MetropolitanArea", ->
	metro = null
	
	beforeEach ->
		metro = new TodoApp.MetropolitanArea
		
	describe "list", ->
		list = TodoApp.MetropolitanArea.list()
			
		it "should contain 80 entries", ->
			expect(list.length).toEqual 80
		
		it "should contain 'no waiver'", ->
			expect(_.include(list, 'no waiver')).toBe true
		
		it "should contain 'standard waiver'", ->
			expect(_.include(list, 'standard waiver')).toBe true
		
		it "should contain 'maximum waiver'", ->
			expect(_.include(list, 'maximum waiver')).toBe true
	
	describe "inheritance from TodoApp.SingletonLikeModel", ->

		it "should be an instance of TodoApp.SingletonLikeModel", ->
			expect(metro instanceof TodoApp.SingletonLikeModel).toBe true

		it "should implement abstract localStorage class method", ->
			expect(TodoApp.MetropolitanArea.localStorage() instanceof Store).toBe true
			expect(TodoApp.MetropolitanArea.localStorage().name).toEqual "metropolitanArea"
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(metro.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'metropolitanArea'", ->
			expect(metro.localStorage.name).toEqual 'metropolitanArea'
	
	describe "toJSON", ->
		it "should be the hash expected", ->
			attrs = {id: 123323}
			expected = {value: "New York, NY"}
			_.extend attrs, expected
			metro.set attrs
			expect(metro.toJSON()).toEqual expected