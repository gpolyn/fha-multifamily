describe "SingletonLikeModel", ->
	# modelImpl = null
	# someObj = {furt: "furt"}
	# class ModelImplForTesting extends TodoApp.SingletonLikeModel
	# 	mock = {}
	# 	mock.findAll = -> [someObj]
	# 		
	# 	@localStorage: -> mock
	
	
	describe "getInstance", ->
		
		describe "when instance already exists in local storage", ->
			someObj = {furt: "furt"}
			class ModelImplForTesting extends TodoApp.SingletonLikeModel
				mock = {}
				mock.findAll = -> [someObj]
				@localStorage: -> mock
				
			it "should return object with same attributes as for entity that already exists", ->
				expect(ModelImplForTesting.getInstance().attributes).toEqual someObj
			
			it "should return object of the same instance as that calling getInstance", ->
				expect(ModelImplForTesting.getInstance() instanceof ModelImplForTesting).toBe true
		
		it "should return an instance of the object if it does not already exist", ->
			class ModelImplForTesting extends TodoApp.SingletonLikeModel
				mock = {}
				mock.findAll = -> []

				@localStorage: -> mock
			expect(ModelImplForTesting.getInstance() instanceof ModelImplForTesting).toBe true
	
	