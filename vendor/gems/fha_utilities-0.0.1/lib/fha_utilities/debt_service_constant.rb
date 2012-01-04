module FhaUtilities
  
  class DebtServiceConstant
    
    include Singleton
    
    def initialize
      BigDecimal.mode(BigDecimal::ROUND_MODE, BigDecimal::ROUND_HALF_EVEN)
      BigDecimal.limit(20)
      @big_decimal_12 = BigDecimal("12")
      @big_1 = BigDecimal("1")
      @big_100 = BigDecimal("100")
    end
    
    def get_percent(args)
      (get_decimal(args) * @big_100).to_f
    end
    
    def get_decimal(args)
      modified_rate = args[:mortgage_interest_rate].to_f/100
      big_rate = BigDecimal(modified_rate.to_s)
      per = big_rate/@big_decimal_12
      denom = @big_1 - @big_1/(@big_1 + per)**args[:term_in_months]
      x = per/denom
      big_mip = BigDecimal(args[:mortgage_insurance_premium_rate].to_s)/@big_100
      result = (x * @big_decimal_12 + big_mip)
      return result.to_f
    end
    
  end
end