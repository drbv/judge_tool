module ReopenedAttributes
  def reopened?
    reopened > 0
  end

  def attr_reopened?(attribute)
    reopened_attributes.include?(attributes_group(attribute))
  end

  def reopened_attributes
    @reopened_attributes ||= discussable_attributes.select.with_index {|_attr, index| bin_reopen[index] == '1'}
  end

  def reopen!(attributes)
    update_attribute :reopened, (attributes.inject(0) {|memo, attr| memo += reopen_value(attr)})
  end

  def close!
    update_attribute :reopened, 0
  end

  private

  def attributes_group(attribute)
    attribute.to_sym
  end

  def bin_reopen
    @bin_reopen ||= reopened.to_s(2).chars.reverse
  end

  def reopen_mapping
    @reopen_mapping ||= Hash[discussable_attributes.map.with_index{|attr, index| [attr, 2**index]}]
  end

  def reopen_value(attr)
    reopen_mapping[attr.to_sym]
  end

end