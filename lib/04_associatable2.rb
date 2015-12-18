require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_class = through_options.model_class
      source_options = through_class.assoc_options[source_name]

      through_foreign_key = through_options.send(:foreign_key)
      through_object =
          through_class.where(id: self.send(through_foreign_key)).first

      source_foreign_key = source_options.send(:foreign_key)
      source_options.model_class
        .where(id: through_object.send(source_foreign_key)).first
    end
  end
end
