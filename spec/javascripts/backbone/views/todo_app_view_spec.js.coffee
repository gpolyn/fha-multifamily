# describe "AppView", ->
# 	app_view = null
# 	todo_view = null
# 	todoRenderSpy = null
# 	todoViewStub = null
# 	todo1 = null
# 	todo2 = null
# 	todo3 = null
# 	todo_list = null
# 	
# 	beforeEach ->
# 		todo1 = new Backbone.Model id: 1
# 		todo2 = new Backbone.Model id: 2
# 		todo3 = new Backbone.Model id: 3
# 		todo_list = new TodoApp.TodoList [todo1, todo2, todo3]
		# app_view = new TodoApp.AppView collection: todo_list
	
	
	# describe "rendering stats template", ->
	# 	beforeEach ->
	# 		loadFixtures("_stats_template.html")
	# 		app_view = new TodoApp.AppView collection: todo_list
	# 		
	# 	it "should be defined after initialization", ->
	# 		expect(app_view.statsTemplate).toBeDefined()
	# 	
	# 	it "should load the template with the stats", ->
	# 		handlerbarsCompiler = TodoApp.template '#stats-template'
	# 		expected = handlerbarsCompiler model.toJSON()
	# 		expect(view.template model.toJSON()).toEqual(expected)
	# 
	
	# describe "The Main Event", ->
	# 	
	# 	beforeEach ->
	# 		# setFixtures('<div id="todos"></div>')
	# 		# loadFixtures("_stats_template.html", "_item_template.html")
	# 		todo_view = new Backbone.View
	# 		todo_view.render ->
	# 			this.el = document.createElement('li')
	# 			return this
	# 		todoRenderSpy = sinon.spy(todo_view, 'render')
	# 		todoViewStub = sinon.stub(window, 'TodoView').returns(todo_view)
	# 		app_view = new TodoApp.AppView collection: todo_list
	# 		# app_view.render()
	# 
	# afterEach ->
	# 	todoViewStub.restore()
	# 	
	# it "creates a Todo view for each todo item", ->
	# 	expect(todoViewStub).toHaveBeenCalledThrice()
	# 	expect(todoViewStub).toHaveBeenCalledWith({model:todo1})
	# 	expect(todoViewStub).toHaveBeenCalledWith({model:todo2})
	# 	expect(todoViewStub).toHaveBeenCalledWith({model:todo3})

# 	describe "Instantiation", ->
# 		it "should be associated with existing div", ->
# 			expect(app_view.el.nodeName).toEqual("DIV")
  