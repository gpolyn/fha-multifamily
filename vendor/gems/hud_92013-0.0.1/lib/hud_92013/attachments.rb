module Hud92013
  module Attachments
    module DevelopmentCosts
      @@attributes = [:initial_deposit_to_reserve_fund, :estimate_of_repair_cost,
                      :fha_inspection_fee, :financing_fee, :mortgageable_bond_costs,
                      :discount, :permanent_placement_fee, :legal_and_organizational,
                      :title_and_recording, :fha_exam_fee, :first_year_mip,
                      :third_party_reports, :survey, :other]
      
      @@attributes.each {|attr| define_method(attr) {super()}}
      
      # def self.extended(base)
      #   unless base.respond_to?(:fart)
      #       raise NoMethodError, 'Fart'
      #   end
      # end
      # 
      # def self.included(base)
      #   p "#{self} included in #{base}"
      #   p "#{base} respond_to? :fart #{base.respond_to?(:fart)}"
      #           p "#{base} respond_to? :fart #{base.respond_to?(:method_name)}"
        # raise(NotImplementedError, "fuck") unless base.respond_to?(:initial_deposit_to_reserve_fund)
        # unless base.respond_to?(:fart)
        #   base.instance_eval do
        #     def self.new(*sub)
        #       msg = "Not all required read attributes have been implemented"
        #       raise NotImplementedError, msg
        #     end
        #   end
        # end
      # end
      
      # def self.included(c)
      #   p "hi"
      #   responds_to_all_required_methods = true
      #   [:initial_deposit_to_reserve_fund].each {|attr| responds_to_all_required_methods = false and break unless c.respond_to?(attr)}
      #   # p "respond_to #{responds_to_all_required_methods}"
      #   p "c instance methodd #{c.instance_methods}"
      #   p "my rsp #{c.respond_to?(:initial_deposit_to_reserve_fund)}"
      #   unless responds_to_all_required_methods
      #     # c.instance_eval do
      #       # def self.new(*sub)
      #         msg = "Not all required read attributes have been implemented"
      #         raise NotImplementedError, msg
      #       # end
      #     # end
      #   end
      # end
      
      def total_development_costs
        @@attributes.inject(0) {|sum, attr| sum + send(attr).to_f }
      end
      
    end
  end
  
end