require "fha_utilities/version"
require 'active_model'
require 'active_support'
require 'set'
require 'singleton'
require 'bigdecimal'

module FhaUtilities
  autoload :Lease, 'fha_utilities/lease'
  autoload :TaxAbatement, 'fha_utilities/tax_abatement'
  autoload :DebtServiceConstant, 'fha_utilities/debt_service_constant'
end
