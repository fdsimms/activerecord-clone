require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_line = params.map { |key, _| "#{key} = ?" }
    where_line = where_line.join(" AND ")

    results = DBConnection.execute(<<-SQL, *(params.values))
      SELECT * FROM #{self.table_name} WHERE #{where_line}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
