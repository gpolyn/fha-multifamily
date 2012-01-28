class TodoApp.LoanSubmission extends TodoApp.SingletonLikeModel
	
	@localStorage: -> new Store "loanSubmission"
	
	localStorage: @localStorage()