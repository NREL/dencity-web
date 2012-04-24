class String
  def to_value
		result = self
		if self =~ /^true$/i
			result = true
		elsif self =~ /^false$/i
		  result = false
	  elsif self =~ /\A[+-]?\d+?(\.\d+)?\Z/
  		result = self.to_f.prettify
		end

		result
	end
end