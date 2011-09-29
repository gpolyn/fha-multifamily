# describe "destroy", ->
# 	model = null
# 	view = null
# 	todoValue = "Spork!"
# 	
# 	beforeEach ->
# 		setFixtures('<ul id="todo-list"></ul>')
# 		loadFixtures("_item_template.html")
# 		model = new Backbone.Model id: 1, content: todoValue, done: false
# 		view = new TodoApp.TodoView model: model
# 	
# 	it "destroys the model using...", ->
# 		# todoValue = "spt"
# 		# loadFixtures("_item_template.html")
# 		# setFixtures('<ul id="todo-list"></ul>')
# 		# loadFixtures("_item_template.html")		
# 		# model2 = new TodoApp.Todo id: 1, content: todoValue, done: false
# 		# expect(model.get("content")).toEqual(todoValue)
# 		# setFixtures('<ul id="todo-list"></ul>')
# 		# spyOn(model2, "destroy")#.andCallThrough()
# 		# spy = sinon.spy(model, "get")
# 		# spy = sinon.spy(model2, "destroy")
# 		# sinon.stub(Backbone, "sync")
# 		# view2 = new TodoApp.TodoView model: model2
# 		# spy = sinon.spy(view, "destroy")
# 		# spyOn(view2, "destroy")
# 		$('ul#todo-list').append(view.render().el)
# 		expect($('ul#todo-list').innerHTML).toContain("spark")
# 		# li = $('ul#todo-list li:first')
# 		# expect(li.find('span.todo-destroy')).toContain("fart")
# 		expect(li.find('span.todo-destroy')).toExist()
# 		# expect(model.get("done")).toEqual(false)
# 		# model2.destroy()
# 		# foo.not(7==7)
# 		li.find('span.todo-destroy').trigger('click') #toContain("fart") #.trigger('click')
# 		# expect(li.find('span.todo-destroy')).toContain("fart")
# 		expect(spy.called).toBe(true)
# 		# expect(view2.destroy).not.toHaveBeenCalled()