class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
  
  # Remove all inner hash structure and leave hash key-value pairs at one level, only
  def convert_to_first_level
    hash = Hash.new
    proc = Proc.new {|k,v| v.is_a?(Hash) ? v.each(&proc) : hash[k] = v}
    each &proc
    hash
  end
  
end