class TodoApp.HighCostPercentage extends TodoApp.SingletonLikeModel
	
	@localStorage: -> new Store "highCostPercentage"
	
	localStorage: @localStorage()
	