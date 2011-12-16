describe "Sec223fAcquisitionLoan", ->
	server = null
	loan = null
	options = null
	
	beforeEach ->
		loan = new TodoApp.Sec223fAcquisitionLoan
		server = sinon.fakeServer.create()
		server.respondWith(
			[200,
			{"Content-Type": "application/json"},
			'{"criterion": 3, "loanAmount": 4000}']
			)
	
	afterEach ->
		server.restore()
	
	it "should make the correct request", ->
		loan.fetch()
		expect(server.requests.length).toEqual 1
		expect(server.requests[0].method).toEqual "GET"
		expect(server.requests[0].url).toEqual("/sec223f_acquisition_loan")
	
	it "should do something", ->
		console?.log "should change the object"
		spy = sinon.spy()
		# options.success = spy
		options = {success: spy}
		loan.fetch(options)
		server.respond()
		expect(spy.calledOnce).toBeTruthy()