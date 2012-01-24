# describe "LoanCriterion", ->
# 	criterion = null
# 	
# 	describe "validation", ->
# 		eventSpy = null
# 		validAttrs = null
# 		errorMsg = null
# 
# 		beforeEach ->
# 			validAttrs =
# 				criterion: 3
# 				loanAmount: 1000000
# 			criterion = new TodoApp.LoanCriterion
# 			eventSpy = sinon.spy()
# 			criterion.bind("error", eventSpy)
# 
# 		afterEach ->
# 			criterion.save validAttrs
# 			expect(eventSpy.calledOnce).toBeTruthy()
# 			expect(eventSpy.calledWith(criterion, [errorMsg])).toBeTruthy()
# 
# 		describe "loanAmount", ->
# 			beforeEach ->
# 				errorMsg = "Loan amount must be greater than or equal to 0"
# 
# 			xit "must be a number greater than 0", ->
# 				validAttrs.loanAmount = -0.01
# 
# 			xit "cannot be blank", ->
# 				validAttrs.loanAmount = null
# 		
# 		describe "criterion", ->
# 			beforeEach ->
# 				errorMsg = "Criterion must be one of 1, 3, 4, 5 or 7"
# 
# 			xit "must be a number in given range", ->
# 				validAttrs.criterion = 2
# 
# 			xit "cannot be blank", ->
# 				validAttrs.criterion = null