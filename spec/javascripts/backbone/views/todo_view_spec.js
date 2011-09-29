// describe("TodoApp.AppView", function() {
//   
//   beforeEach(function() {
// 	  this.storageStub = sinon.stub(Backbone, "sync")
// 	  this.todo1 = new Backbone.Model({id:1});
//       this.todo2 = new Backbone.Model({id:2});
//       this.todo3 = new Backbone.Model({id:3});
//       this.collection = new Backbone.Collection([
//         this.todo1,
//         this.todo2,
//         this.todo3
//       ]);
//     this.view = new TodoApp.AppView({collection: this.collection});
// 	this.view.render();
  // });

  // describe("Rendering", function() {
//     
//     beforeEach(function() {
//       this.todoView = new Backbone.View();
//       this.todoView.render = function() {
//         this.el = document.createElement('li');
//         return this;
//       };
//       this.todoRenderSpy = sinon.spy(this.todoView, "render");
//       this.todoViewStub = sinon.stub(window.TodoApp, "TodoView")
//         .returns(this.todoView);
//       this.view.render();
//     });
//     
//     afterEach(function() {
//       // window.TodoApp.TodoView.restore();
// 	  this.storageStub.restore();
//     });
//     
//     it("creates a Todo view for each todo item", function() {
//       expect(this.todoViewStub).toHaveBeenCalledThrice();
//       expect(this.todoViewStub).toHaveBeenCalledWith({model:this.todo1});
//       expect(this.todoViewStub).toHaveBeenCalledWith({model:this.todo2});
//       expect(this.todoViewStub).toHaveBeenCalledWith({model:this.todo3});
//     });
//     
//     // it("renders each Todo view", function() {
//     //   expect(this.todoRenderSpy).toHaveBeenCalledThrice();
//     // });
//     // 
//     // it("appends the todo to the todo list", function() {
//     //   expect($(this.view.el).children().length).toEqual(3);
//     // });
//     
  // });
//   
// });