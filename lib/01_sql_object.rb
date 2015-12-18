require_relative 'db_connection'
require 'active_support/inflector'
# require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    columns = DBConnection.execute2(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL
    @columns = columns[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") do |new_value|
        attributes[column] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT * FROM #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    parsed_results = []
    results.each do |attributes|
      parsed_results << self.new(attributes)
    end

    parsed_results
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT * FROM #{table_name} WHERE id = ? LIMIT 1
    SQL

    parse_all(results).first
  end

  def initialize(params = {})

    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end

    self.class.finalize!
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| send("#{column}") }
  end

  def insert
    # byebug
    col_names = self.class.columns.join(", ")
    num_attributes = attribute_values.length
    question_marks = (['?'] * num_attributes).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL
    send("id=", DBConnection.last_insert_row_id)
  end

  def update
    set_str = self.class.columns.map { |col| "#{col} = ?"}.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
      SET #{set_str}
      WHERE id = ?
    SQL
  end

  def save
    (id.nil?) ? insert : update
  end
end
