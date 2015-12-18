require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.singularize.constantize
  end

  def table_name
    "#{class_name}s".downcase
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    options_default = {
      foreign_key: "#{name.to_s.singularize}_id".underscore.to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.capitalize
    }
    options = options_default.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    options_default = {
      foreign_key: "#{self_class_name.to_s.singularize}_id".underscore.to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.capitalize
    }
    options = options_default.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = options.foreign_key
      model_class = options.send(:model_class)
      model_class.where(id: self.send(foreign_key)).first
    end
  end

  def has_many(name, options = {})
    self_class_name = "#{self.to_s.underscore.singularize}".to_sym
    options = HasManyOptions.new(name, self_class_name, options)

    define_method(name) do
      foreign_key = options.foreign_key
      model_class = options.send(:model_class)

      model_class.where(foreign_key => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
