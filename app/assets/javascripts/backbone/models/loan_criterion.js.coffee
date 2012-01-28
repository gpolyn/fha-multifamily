class TodoApp.LoanCriterion extends Backbone.Model
	
	validate: (attrs) ->
		errors = []
		unless attrs.loanAmount? and attrs.loanAmount >= 0
			errors.push "Loan amount must be greater than or equal to 0"
		if [1, 3, 4, 5, 7, 10, 11].indexOf(parseInt(attrs.criterion)) is -1
			errors.push "Criterion must be one of 1, 3, 4, 5, 7, 10 or 11"
		# console.log "validating criterion and errors are #{errors.length}...#{errors[0]}"
		errors if errors.length > 0
	
class TodoApp.LoanCriteria extends Backbone.Collection
	
	url: "sizemymultifamilyloan.com/api/beta1/sec223f_acquisition.json"
	
	localStorage: new Store("loanResults")
	
	model: TodoApp.LoanCriterion
	
	comparator: (criterion) ->
		criterion.get('loanAmount')
	
	limitingCriterion: ->
		return if @isEmpty()
		@at(0).get('criterion')
	
	loanAmount: ->
		return if @isEmpty()
		@at(0).get('loanAmount')
	
	parse: (res) ->
		ret_arr = []
		console.log "res is #{JSON.stringify(res)}"
		_.each res, (ele) ->
			ret_arr.push {loanAmount: ele.loanAmount, criterion: ele.criterion, id: ele.id} if ele.criterion?
		ret_arr
	
	plarse: (res) ->
		ret_arr = []
		console.log "res is #{JSON.stringify(res)}"
		_.each [1,3,4,5,7,10,11], (critNo) ->
			console.log "criterion is #{critNo}"
			loanAmount = null
			
			if res.loan["criterion_#{critNo}"]?
				switch critNo
					when 1
						loanAmount = res.loan["criterion_#{critNo}"].loan_request
					when 3
						loanAmount = res.loan["criterion_#{critNo}"].line_e.line_a_minus_line_d
					when 4
						loanAmount = res.loan["criterion_#{critNo}"].line_g.line_d_or_line_e_minus_line_f
					when 5
						loanAmount = res.loan["criterion_#{critNo}"].line_j.line_h_plus_line_i
					when 7
						loanAmount = res.loan["criterion_#{critNo}"].line_h.result
					when 10
						loanAmount = res.loan["criterion_#{critNo}"].line_i.greater_of_line_g_or_line_h
					when 11
						loanAmount = res.loan["criterion_#{critNo}"].line_c.line_a_minus_line_b
					else
						# no-op, for now...
				res.loan["criterion_#{critNo}"].criterion = critNo
				res.loan["criterion_#{critNo}"].loanAmount = loanAmount
				ret_arr.push res.loan["criterion_#{critNo}"]
		ret_arr
		
	fletch: (options) ->
		options || (options = {})
		collection = @
		success = options.success
		options.success = (resp) ->
			collection[if options.add then 'add' else 'refresh'](collection.parse(resp), options)
			console.log "collection from succes is #{JSON.stringify(collection[0])}"
			success(collection, resp) if (success)

		error = options.error
		options.error = (resp) ->
			if error
				error collection, resp, options
			else
				collection.trigger 'error', collection, resp, options
		
		params =
			type:        'POST'
			dataType:    'json'
			url:          @url
			contentType: 'application/json'
			data:        options.data
				
		if Backbone.emulateJSON
			params.contentType = 'application/x-www-form-urlencoded'
			params.data        = if options.data then {model : options.data} else {}
			
		_.extend params, options
		$.ajax(params)
		@
	
	destroyAll: ->
		_(@each (crit) -> crit.destroy()) while @length > 0 # WTF?
	
	validRefinance: ->
		loan:{
			criterion_1:{
				loan_request:6750000
				},
			criterion_3:{
				line_a:{value_in_fee_simple:8000000,percent_multiplier:87.0,net_value:6960000.0},
				line_b_1:{value_of_leased_fee:null},
				line_b_3:{excess_unusual_land_improvement:100000},
				line_b_4:{cost_containment_mortgage_deduction:100000},
				line_b_5:{total_lines_1_to_4:174000.0},
				line_c:{unpaid_balance_of_special_assessments:20000},
				line_d:{total_line_b_plus_line_c:194000.0},
				line_e:{line_a_minus_line_d:6766000}
				},
			criterion_4:{
				line_a:{
					number_of_no_bedroom_units:{units:5,per_family_unit_limit:215342.55,total:1076712.75},
					number_of_one_bedroom_units:{units:5,per_family_unit_limit:241181.55,total:1205907.75},
					number_of_two_bedroom_units:{units:5,per_family_unit_limit:295739.10,total:1478695.5},
					number_of_three_bedroom_units:{units:1,per_family_unit_limit:370761.3,total:370761.3},
					number_of_four_or_more_bedroom_units:{units:5,per_family_unit_limit:418810.5,total:2094052.5}},
				line_b:{cost_not_attributable_to_dwelling_use:2400000.0,percent_multiplier:87.0,result:2088000.0},
				line_c:{warranted_price_of_land:100000,percent_multiplier:87.0,result:87000.0},
				line_d:{total_lines_a_through_c:8401129.8},
				line_e:{total_number_of_spaces:null},
				line_f:{sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments:20000.0},
				line_g:{line_d_or_line_e_minus_line_f:8381100}
				},
			criterion_5:{
				line_a:{mortgage_interest_rate:4.95},
				line_b:{mortgage_insurance_premium_rate:0.45},
				line_c:{initial_curtail_rate:1.0680398921210728},
				line_d:{sum_of_above_rates:6.468039892121073},
				line_e:{net_income:651650.0,effective_income:566935.5,percent_multiplier:87.0},
				line_f:{annual_ground_rent:null,annual_special_assessment:20000,sum:20000.0},
				line_g:{line_e_minus_line_f:546935.5},
				line_h:{line_g_divided_by_line_d:8455969.8},
				line_i:{tax_abatement_present_value:null},
				line_j:{line_h_plus_line_i:8455900}
				},
			criterion_10:{
				line_a:{total_existing_indebtedness:4000000},
				line_b:{required_repairs:100000},
				line_c:{other_fees:24000.0},
				line_d:{loan_closing_charges:211418.83},
				line_e:{sum_of_line_a_through_line_d:4335418.83},
				line_f:{sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment:50000.0},
				line_g:{line_e_minus_line_f:4285400},
				line_h:{eighty_percent_multiplier:80.0, value:8000000, result:6400000},
				line_i:{greater_of_line_g_or_line_h:6400000}
				},
			criterion_11:{
				line_a:{project_cost:3332900},
				line_b1:{grants_loans_gifts:200000.0},
				line_b2:{tax_credits:500000},
				line_b3:{value_of_leased_fee:null},
				line_b4:{excess_unusual_land_improvement_cost:100000},
				line_b5:{cost_containment_mortgage_deductions:100000},
				line_b6:{unpaid_balance_of_special_assessment:20000},
				line_b7:{sum_of_lines_1_through_6:920000.0},
				line_c:{line_a_minus_line_b:2412900.0}
				},
			maximum_insurable_mortgage: 2412900.0
			}
		total_estimated_cash_requirement: 1110726
	
	validPurchase: ->
		validP = jQuery.extend(true, {}, @validRefinance())
		delete validP.loan.criterion_10
		validP.loan.criterion_7 =
			line_a:{purchase_price_of_project:5050000},
			line_b:{repairs_and_improvements:100000},
			line_c:{other_fees:24000.0},
			line_d:{loan_closing_charges:223525.9},
			line_e:{sum_of_line_a_through_line_d:5397525.9},
			line_f:{sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment:50000.0},
			line_g:{line_e_minus_line_f:5347525.9},
			line_h:{percent_multiplier:87.0,result:4652300}
		validP.loan.maximum_insurable_mortgage = 111100
		validP