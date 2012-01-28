# This file, named "a", is contrived to load first -- pending introduction of some kind of
# javascript modularization solution, e.g., require.js.

# Some app-wide helpers...

TodoApp.currencyFormatted = (amount) ->
	i = parseFloat(amount)
	i = 0.00 if isNaN(i)
	minus = ''
	minus = '-' if(i < 0)
	i = Math.abs(i)
	i = parseInt((i + .005) * 100)
	i = i / 100
	s = new String(i)
	s += '.00' if(s.indexOf('.') < 0)
	s += '0' if(s.indexOf('.') == (s.length - 2))
	s = minus + s
	return s

TodoApp.commaFormatted = (amount) ->
	delimiter = ","
	a = amount.split('.',2)
	d = a[1]
	i = parseInt(a[0])
	return '' if isNaN(i)
	minus = ''
	minus = '-' if(i < 0)
	i = Math.abs(i)
	n = new String(i)
	a = []
	while n.length > 3
		nn = n.substr(n.length-3)
		a.unshift(nn)
		n = n.substr(0,n.length-3)
		
	a.unshift(n) if n.length > 0
	n = a.join(delimiter)
	if d.length < 1
		amount = n
	else
		amount = n + '.' + d
	amount = minus + amount
	return amount

TodoApp.dollarFormattingZeroPlaces = (amt) ->
	"$ " + TodoApp.commaFormatted(new String(Math.round(amt))+".")

TodoApp.dollarFormatting = (amt) ->
	"$ " + TodoApp.commaFormatted(TodoApp.currencyFormatted(amt))

TodoApp.isNumber = (n) ->
	!isNaN(parseFloat(n)) and isFinite(n)

# This class works with the local storage mechanism -- though, crudely -- to obtain
# one and only one instance of the implementing model. I don't know if this satisfies any classical
# definition(s) of the 'singleton' pattern, but the met intent seems the same.
class TodoApp.SingletonLikeModel extends Backbone.Model
	
	@localStorage: -> throw new Error("SingletonLikeModel is abstract")
	
	@getInstance: (attrs) ->
		
		if @localStorage
			item = _.find(@localStorage().findAll(), (ele) -> ele?)
			instance = new @ item
			instance.id = 1
			instance
		else
			if attrs
				attrs.id = 1
				new @ attrs
			else
				new @ {id: 1}
	