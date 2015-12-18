require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.class.assoc_options[through_name]
    source_options = self.class.assoc_options[source_name]


    define_method(name) do
      foreign_key = options.foreign_key
      model_class = options.send(:model_class)
      model_class.where(id: self.send(foreign_key)).first
    end
  end
end
