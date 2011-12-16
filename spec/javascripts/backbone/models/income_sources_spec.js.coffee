# test implementation
class TestIncomeSource extends Backbone.Model

describe "IncomeSources", ->
	incomeSources = null
	incomeSourceArr = [new TestIncomeSource, new TestIncomeSource, new TestIncomeSource]
	
	beforeEach ->
		incomeSources = new TodoApp.IncomeSources incomeSourceArr
	
	describe "totalAnnualIncome", ->
		it "should be the sum of model grossAnnualIncome values", ->
			TestIncomeSource::grossAnnualIncome = -> 100
			expected = 100 * 3
			expect(incomeSources.totalAnnualIncome()).toEqual expected
	

	describe "totalSquareFeet", ->

		it "should be the sum of model totalSquareFeet values when all have square feet", ->
			srcWithSF1 = new TestIncomeSource
			srcWithSF1.totalSquareFeet = -> 100
			srcWithSF2 = new TestIncomeSource
			srcWithSF2.totalSquareFeet = -> 400
			srcWithSF3 = new TestIncomeSource
			srcWithSF3.totalSquareFeet = -> 500
			arr = [srcWithSF3, srcWithSF1, srcWithSF2]
			incomeSources = new TodoApp.IncomeSources arr
			expect(incomeSources.totalSquareFeet()).toEqual 100 + 400 + 500
		
		it "should be the sum of any model square feet values when not all have square feet", ->
			srcWithSF1 = new TestIncomeSource
			srcWithSF1.totalSquareFeet = -> 100
			srcWithSF2 = new TestIncomeSource
			srcWithSF2.totalSquareFeet = -> 400
			srcWithoutSF = new TestIncomeSource
			srcWithoutSF.totalSquareFeet = ->
			arr = [srcWithoutSF, srcWithSF1, srcWithSF2]
			incomeSources = new TodoApp.IncomeSources arr
			expect(incomeSources.totalSquareFeet()).toEqual 100 + 400
		
		
	describe "allSquareFootageIsProvided", ->
		squareFootageSources = null
		
		beforeEach ->
			source = new TestIncomeSource {squareFeet: 100}
			squareFootageSources = [source, source.clone(), source.clone()]
		
		it "should be true if each source has square footage", ->
			incomeSources = new TodoApp.IncomeSources squareFootageSources
			expect(incomeSources.allSquareFootageIsProvided()).toBe true
		
		it "should be false if at least one source has no square footage", ->
			badSource = new TestIncomeSource
			squareFootageSources[1] = badSource
			incomeSources = new TodoApp.IncomeSources squareFootageSources
			expect(incomeSources.allSquareFootageIsProvided()).toBe false
		