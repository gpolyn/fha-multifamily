# This file, named "a", is contrived to load first -- pending introduction of some kind of
# javascript modularization solution, e.g., require.js.

# This class works with the local storage mechanism -- though, crudely -- to obtain
# one and only one instance of the implementing model. I don't know if this satisfies any classical
# definition(s) of the 'singleton' pattern, but the met intent seems the same.
class TodoApp.SingletonLikeModel extends Backbone.Model
	
	@localStorage: -> throw new Error("SingletonLikeModel is abstract") #new Store "sec223fAcquisitionCosts"
	
	@getInstance: ->
		return new @ inst if (inst = @localStorage().findAll()[0])?
		instance = new @
	