module FhaUtilities
    
  module TaxAbatement
    
    module Phase
      
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      ATTRIBUTES = [:start_year, :end_year, :annual_amount]
      
      attr_accessor *ATTRIBUTES
      
      included do
        validates :annual_amount, :numericality => {:greater_than_or_equal_to => 0}
        validates :start_year, :end_year, 
                  :numericality => {:greater_than_or_equal_to => 0, :only_integer=>true}
        validates :end_year, :numericality=>{:greater_than=>:start_year}, 
                  :if=>Proc.new{|a| a.start_year && a.end_year && a.end_year >= 0}
      end

      def initialize(args={})
        self.attributes = args
      end

      def attributes
        ATTRIBUTES.inject({}) do |result, key|
          result[key.to_sym] = send(key)
          result
        end
      end

      def attributes=(attrs)
        attrs.each_pair {|k, v| send("#{k}=", v)}
      end
      
    end
  end
  
  module TaxAbatement
    
    module CommonAttributes
      extend ActiveSupport::Concern
      attr_accessor :loan_term_in_months, :mortgage_interest_rate_percent,
                    :mortgage_insurance_premium_percent
      
      included do
        validates :mortgage_insurance_premium_percent, :mortgage_interest_rate_percent,
                  :numericality => {:greater_than_or_equal_to => 0}
        validates :loan_term_in_months,
                  :numericality => {:greater_than_or_equal_to => 0, :only_integer=>true}
        validates :mortgage_insurance_premium_percent, :mortgage_interest_rate_percent,
                  :numericality => {:less_than_or_equal_to=>100, :allow_blank=>true}
      end
    end
    
    module Fixed
      extend ActiveSupport::Concern
      include TaxAbatement::Phase
      include TaxAbatement::CommonAttributes
                    
      def initialize(args={})
        super args
        @start_year = 0
      end
      
      def start_year=(val)
        # intentionally left blank
      end
      
      def present_value
        if end_year >= loan_term_in_months.to_f/12
          return 0
        else
          attributes = {:mortgage_interest_rate=>mortgage_interest_rate_percent,
                        :mortgage_insurance_premium_rate => mortgage_insurance_premium_percent,
                        :term_in_months=> end_year * 12}
          return (annual_amount.to_f/FhaUtilities::DebtServiceConstant.instance.get_decimal(attributes)).round(2)
        end
      end
      
    end
    
    module Variable
      
      class Phase
        include TaxAbatement::Phase
        
        attr_accessor :attribute_sym_name
        
        def <=>(other)
          start_year <= other.start_year ? -1 : 1
        end
        
        def eql?(other)
          attribute_sym_name == other.attribute_sym_name
        end
        
        def hash
          12345 # don't give a shit about this kind of identity for set
        end
        
      end
      
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include TaxAbatement::CommonAttributes
      
      included do
        validate :phases_do_not_overlap
      end
      
      def contents
        phase_attribute_store
      end
      
      def valid?
        ret = super
        
        phase_attribute_store.each do |phase|
          unless phase.valid?
            phase.errors.full_messages.each do |err_msg|
              errors.add(phase.attribute_sym_name, err_msg.downcase)
            end
            ret = false
          end
        end
        
        ret
      end
      
      def initialize(args={})
        self.attributes = args
      end

      def method_missing sym, *args
        if sym =~ /^variable_phase_(\d+)=$/
          modified = sym.to_s.chop
          var = Variable::Phase.new(*args)
          instance_variable_set "@#{modified}", var
          var.attribute_sym_name = modified.to_sym
          # obj = phase_attribute_store.find {|i| i.attribute_sym_name == var.attribute_sym_name}
          # self.phase_attribute_store.delete obj if obj
          self.phase_attribute_store << var
        elsif sym =~ /^variable_phase_(\d+)$/
          instance_variable_get "@#{sym}"
        else
          super
        end
      end
      
      def attributes
        phase_attribute_store.inject({}) do |result, key|
          result[key.attribute_sym_name] = key
          result
        end
      end
      
      def attributes=(attrs)
        attrs.each_pair {|k, v| send("#{k}=", v)}
      end
      
      def respond_to?(meth)
        if meth.to_s =~ /^variable_phase_(\d+)(=?)$/
          true
        else
          super
        end
      end
      
      def present_value
        reverse_sorted_abatements = phase_attribute_store.to_a.reverse
        dsc = FhaUtilities::DebtServiceConstant.instance
        attrs = {:mortgage_interest_rate=>mortgage_interest_rate_percent,
                 :mortgage_insurance_premium_rate => mortgage_insurance_premium_percent}
        reduce_by = 0
        
        result = reverse_sorted_abatements.inject(0) do |result, abatement|
          attrs[:term_in_months] = abatement.end_year * 12
          result += (abatement.annual_amount - reduce_by)/dsc.get_decimal(attrs)
          reduce_by = abatement.annual_amount
          result
        end
        result.round(2)
      end
      
      protected
      
      def phase_attribute_store
        @phase_attribute_store ||= SortedSet.new
      end
      
      def phases_do_not_overlap
        arr = phase_attribute_store.sort.to_a

        (1..arr.size-1).each do |i|
           if arr[i-1].end_year > arr[i].start_year
             humanized_attribute_label = arr[i-1].attribute_sym_name.to_s.humanize.downcase
             msg = "must not start before end of #{humanized_attribute_label}"
             errors.add(arr[i].attribute_sym_name, msg)
           end
        end
        rescue
          # just quit validation
      end
      
    end
  end
  
end