module ReopenedAttributes
  def reopened?
    reopened > 0
  end

  def reopened_attributes
    discussable_attributes.select.with_index {|_attr, index| bin_reopen[index] == '1'}
  end

  def reopen!(attributes)
    update_attribute :reopen, (attributes.inject(0) {|memo, attr| memo += reopen_value(attr)})
  end

  private

  def bin_reopen
    @bin_reopen ||= reopen.to_s(2).chars
  end

  def reopen_mapping
    @reopen_mapping ||= Hash[discussable_attributes.map.with_index{|attr, index| [attr, 2**index]}]
  end

  def reopen_value(attr)
    reopen_mapping[attr.to_sym]
  end

end