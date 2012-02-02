describe "TodoView", ->
	model = null
	view = null
	todoValue = "Spork!"
	
	describe "template pre-fetching", ->
		beforeEach ->
			loadFixtures("_item_template.html")
			model = new Backbone.Model id: 1, content: todoValue, done: false
			# model = new TodoApp.Todo id: 1, content: todoValue, done: false
			view = new TodoApp.TodoView model: model
			
		it "should load the template", ->
			expect(view.template).toBeDefined()
		
		it "should load the template with the values in the model", ->
			handlerbarsCompiler = TodoApp.template '#item-template'
			expected = handlerbarsCompiler model.toJSON()
			expect(view.template model.toJSON()).toEqual(expected)
		
	beforeEach ->
		setFixtures('<ul id="todo-list"></ul>')
		model = new Backbone.Model id: 1, content: todoValue, done: false
		# model = new TodoApp.Todo id: 1, content: todoValue, done: false
		view = new TodoApp.TodoView model: model, template: readFixtures("_item_template.html")
		# expect(model.get("content")).toEqual(todoValue)
	
	it "should remove item from dom", ->
		console?.log("test: should remove item from dom")
		$("ul#todo-list").append(view.render().el)
		li = $('ul#todo-list li:first')
		# spy = sinon.spy(model, 'get')
		# expect(model).not.toBe(null)
		view.destroy()
		# model.get("done")
		# li.find('span.todo-destroy').trigger("click")
		# expect(model).toBe(null)
		# expect(spy.called).toBe(true)
		# expect(model.destroy).toHaveBeenCalled()
		expect($('ul#todo-list li:first')).not.toExist()
	
	describe "existence of ul", ->
		it "description", ->
			expect($('ul#todo-list')).toExist()
	
	describe "Root Element", ->
		it "is an LI", ->
			expect(view.el.nodeName).toEqual("LI")
	
	describe "Instantiation", ->
		it "should load the template", ->
			expect(view.template).toBeDefined()
			
	
	describe "Rendering", ->
		it "returns the view object", ->
			expect(view.render()).toEqual(view)
		
		describe "first child of root element", ->
			it "should have class todo when item not 'done'", ->
				view.render()
				expect(view.el.children[0].className).toContain("todo")
				expect(view.el.children[0].className).not.toContain("done")
			
		describe "Template", ->	
			beforeEach ->
				$("ul#todo-list").append(view.render().el)
			
			it "has the correct text", ->
				expect($(view.el).find('div.todo-content')).toHaveText(todoValue)
			
			it "has correct checkbox setting", ->
				expect($(view.el).find('input.check')).not.toBeChecked()
			
			xit "has the correct input field value", ->
				expect($(view.el).find('input.todo-input')).toHaveValue(todoValue)
				expect($(view.el).find('input.todo-input')).not.toBeVisible()
		
		describe "When todo is done", ->
			
			it "has a done class", ->
				model.set done: true, {silent: true}
				$("ul#todo-list").append(view.render().el)
				expect($(view.el).find('div:first-child')).toHaveClass("done")
		
		describe "edit state", ->
			li = null
			
			beforeEach ->
				$("ul#todo-list").append(view.render().el)
				li = $('ul#todo-list li:first')
				target = li.find('div.todo-content')
				expect(target).toExist()
				# spyOn(view, "edit")
				li.find('div.todo-content').trigger('dblclick')
				# expect(view.edit).toHaveBeenCalled()
			
			it "input takes focus", ->
				expect(li.find('.todo-input').is(':focus')).toBe(true)
			
			it "adds 'editing' class", ->
				expect(li).toHaveClass('editing')
		
		# describe "removal state", ->
			
			# it "should remove item from dom", ->
			# 	$("ul#todo-list").append(view.render().el)
			# 	li = $('ul#todo-list li:first')
			# 	expect(model).toExist()
			# 	li.find('span.todo-destroy').trigger("click")
			# 	expect(model).not.toExist()
			# 	expect($('ul#todo-list li:first')).not.toExist()
			
		  