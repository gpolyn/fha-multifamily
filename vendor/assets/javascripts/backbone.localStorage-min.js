// Capture earlier version of sync method for reuse farther below

// var origSync = Backbone.sync;

/**
 * Backbone localStorage Adapter v1.0
 * https://github.com/jeromegn/Backbone.localStorage
 *
 * Date: Sun Aug 14 2011 09:53:55 -0400
 */

// A simple module to replace `Backbone.sync` with *localStorage*-based
// persistence. Models are given GUIDS, and saved into a JSON object. Simple
// as that.

// Generate four random hex digits.
// function S4() {
//    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
// };
// 
// // Generate a pseudo-GUID by concatenating random hexadecimal.
// function guid() {
//    return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4());
// };
// 
// // Our Store is represented by a single JS object in *localStorage*. Create it
// // with a meaningful name, like the name you'd give a table.
// window.Store = function(name) {
//   this.name = name;
//   var store = localStorage.getItem(this.name);
//   this.records = (store && store.split(",")) || [];
// };
// 
// _.extend(Store.prototype, {
// 
//   // Save the current state of the **Store** to *localStorage*.
//   save: function() {
//     localStorage.setItem(this.name, this.records.join(","));
//   },
// 
//   // Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
//   // have an id of it's own.
//   create: function(model) {
//     if (!model.id) model.id = model.attributes.id = guid();
//     localStorage.setItem(this.name+"-"+model.id, JSON.stringify(model));
//     this.records.push(model.id.toString());
//     this.save();
//     return model;
//   },
// 
//   // Update a model by replacing its copy in `this.data`.
//   update: function(model) {
//     localStorage.setItem(this.name+"-"+model.id, JSON.stringify(model));
//     if (!_.include(this.records, model.id.toString())) this.records.push(model.id.toString()); this.save();
//     return model;
//   },
// 
//   // Retrieve a model from `this.data` by id.
//   find: function(model) {
//     return JSON.parse(localStorage.getItem(this.name+"-"+model.id));
//   },
// 
//   // Return the array of all models currently in storage.
//   findAll: function() {
//     return _.map(this.records, function(id){return JSON.parse(localStorage.getItem(this.name+"-"+id));}, this);
//   },
// 
//   // Delete a model from `this.data`, returning it.
//   destroy: function(model) {
//     localStorage.removeItem(this.name+"-"+model.id);
//     this.records = _.reject(this.records, function(record_id){return record_id == model.id.toString();});
//     this.save();
//     return model;
//   }
// 
// });
// 
// // Override `Backbone.sync` to use delegate to the model or collection's
// // *localStorage* property, which should be an instance of `Store`.
// Backbone.sync = function(method, model, options, error) {
// 
//   // Backwards compatibility with Backbone <= 0.3.3
//   if (typeof options == 'function') {
//     options = {
//       success: options,
//       error: error
//     };
//   }
// 
//   var resp;
//   var store = model.localStorage || model.collection.localStorage;
// 
//   switch (method) {
//     case "read":
// 		if(model.id){
// 			
// 		} else {
// 			store.findAll()
// 		}
// 	// resp = model.id ? store.find(model) : store.findAll(); break;
//     case "create":  resp = store.create(model);                            break;
//     case "update":  resp = store.update(model);                            break;
// 	// case "update":
// 	// 	if (options.putToServer == true)
// 	// 		{
// 	// 		resp = origSync(method, model, options, error);
// 	// 		}
// 	// 	else
// 	// 		{
// 	// 		resp = store.update(model);
// 	// 		}
// 	// 	break;
//     case "delete":  resp = store.destroy(model);                           break;
//   }
// 
//   if (resp) {
//     options.success(resp);
//   } else {
//     options.error("Record not found");
//   }
// };

/**
 * Backbone localStorage Adapter v1.0
 * https://github.com/jeromegn/Backbone.localStorage
 *
 * Date: Sun Aug 14 2011 09:53:55 -0400
 */

function S4(){return(((1+Math.random())*65536)|0).toString(16).substring(1)}function guid(){return(S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4())}window.Store=function(b){this.name=b;var a=localStorage.getItem(this.name);this.records=(a&&a.split(","))||[]};_.extend(Store.prototype,{save:function(){localStorage.setItem(this.name,this.records.join(","))},create:function(a){if(!a.id){a.id=a.attributes.id=guid()}localStorage.setItem(this.name+"-"+a.id,JSON.stringify(a));this.records.push(a.id.toString());this.save();return a},update:function(a){localStorage.setItem(this.name+"-"+a.id,JSON.stringify(a));if(!_.include(this.records,a.id.toString())){this.records.push(a.id.toString())}this.save();return a},find:function(a){return JSON.parse(localStorage.getItem(this.name+"-"+a.id))},findAll:function(){return _.map(this.records,function(a){return JSON.parse(localStorage.getItem(this.name+"-"+a))},this)},destroy:function(a){localStorage.removeItem(this.name+"-"+a.id);this.records=_.reject(this.records,function(b){return b==a.id.toString()});this.save();return a}});Backbone.sync=function(f,d,c,b){if(typeof c=="function"){c={success:c,error:b}}var e;var a=d.localStorage||d.collection.localStorage;switch(f){case"read":e=d.id?a.find(d):a.findAll();break;case"create":e=a.create(d);break;case"update":e=a.update(d);break;case"delete":e=a.destroy(d);break}if(e){c.success(e)}else{c.error("Record not found")}};