beforeEach(function() {
  this.templates = _.extend(this.templates || {}, {
    todo: '<a href="#todo/{{id}}"{{#if done}} class="done"{{/if}}>' +
            '<h2>{{title}}</h2>' +
            '<input class="edit" type="text" value="{{title}}" style="display:none"/>' + 
          '</a>' +
          '<a href="#" class="edit">Edit</a>'
  });
});

// %script#item-template{:type => "text/html"}
//   .todo{:class => "{{#done}}done{{/done}}"}
//     .display
//       %input{:class => "check", :type => "checkbox", :"{{#done}}checked{{/done}}" => true}
//       .todo-content
//       %span.todo-destroy
//     .edit
//       %input.todo-input{:type => "text", :value => ""}