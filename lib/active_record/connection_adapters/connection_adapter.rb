module ActiveRecord
  module ConnectionAdapters

    class TableDefinition

      alias_method :original_column, :column

      def column(name, type, options = {})
        method(:original_column).call(name,type,options)
        column = self[name]
        column.cs = options[:cs]
        self
      end
    end
    
    class ColumnDefinition 
      attr_accessor :cs

      alias_method :original_to_sql, :to_sql

      def to_sql
        column_sql = method(:original_to_sql).call
        column_options = {}
        column_options[:cs] = false if (cs.nil? && self.type == 'string')
        column_options[:cs] = cs unless cs.nil?
        add_column_options!(column_sql, column_options) unless type.to_sym == :primary_key
        column_sql
      end
      
      alias to_s :to_sql
    end

    class JdbcAdapter < AbstractAdapter

      def _execute(sql,name = nil)
        if JdbcConnection::select?(sql)
          @connection.execute_query(sql)
        else
          @connection.execute_update(sql)
        end
      end
      
      def supports_migrations? 
        true
      end

      def native_database_types
        {
          :primary_key => "BIGINT",
          :string      => { :name => "VARCHAR", :limit => 255 },
          :text        => { :name => "CLOB" },
          :integer     => { :name => "INTEGER" },
          :float       => { :name => "NUMBER" },
          :decimal     => { :name => "DECIMAL" },
          :datetime    => { :name => "DATETIME" },
          :timestamp   => { :name => "DATETIME-TZ" },
          :time        => { :name => "DATETIME" },
          :date        => { :name => "DATE" },
          :binary      => { :name => "BLOB" },
          :boolean     =>{ :name => "BIT", :limit => 1 } 
        }
      end
    end

    class JdbcColumn < Column

      #TODO remplacer par generation dyna getter setter
      def extended(ext=false)
        @extended = ext
      end

      def extended?
        @extended
      end

      def from_extended_column(val=false)
        @from_extended_column = val
      end

      def from_extended_column?
        @from_extended_column
      end

      def extended_size=(val=0)
        @extended_size = val
      end
      
      def extended_size
        @extended_size
      end

      def case_sensitive=(val=false)
        @case_sensitive = val
      end

      def case_sensitive
        @case_sensitive
      end

      def simplified_type(field_type)
        case field_type
        when /^bigint/i             then :integer
        when /^date/i               then :date
        when /^timestamp_timezone/  then :timestamp
        when /^timestamp/i          then :datetime
        when /^numeric/i            then :decimal  # à vérifier pas de float en progress?
        when /^bit\(1\)$/i          then :boolean
        when /blob/i                then :binary
        when /^varchar/i            then :string
        when /^integer/i            then :integer
        when /^clob/i               then :text
        when /^raw/i                then :binary
        when /^recid/i              then :binary
        end
      end

      def type_cast(value)
        
        case type
        when :timestamp     then value=='NULL' ? value : "'"+value.to_s+"'"
        when :datetime      then value=='NULL' ? value : "'"+value.to_s+"'"
        when :date          then value=='NULL' ? value :  "'"+value.to_s+"'"
        when :integer       then value.nil? ? 'NULL'  : value
        else
          super
        end
      end
    end
   

    module ProgressExtendFields
      def self.limit(ext_col)
        ext_col['width'].to_i/ext_col['array_extent'].to_i
      end

      def self.type(ext_col)
        ext_col['col_subtype'] == 4  ? "INTEGER" : "VARCHAR("+limit(ext_col).to_s+")"
      end

      def self.default_value(ext_col)
        ext_col['col_subtype'] == 4 ? ext_col['dflt_value'].to_i : ext_col['dflt_value']
      end

      def self.names(ext_col)
        name = ext_col['col']
        (1..ext_col['array_extent'].to_i).map do |indice|
          name+"__"+indice.to_s
        end
      end
    end

    module SchemaStatements

      def table_exists?(table_name)
        table = table_name.dup.delete("pub.")
        tables.include?(table.to_s)
      end

      alias_method :original_add_column, :add_column
     
      def add_column(table_name, column_name, type, options = {})
        options[:cs]= false if (!options[:cs] && type.to_s == 'string')
        method(:original_add_column).call(table_name, column_name, type, options)
      end
   
    end
    
    module DatabaseStatements

      def add_limit_offset!(sql, options)
        offset = options[:offset] ? options[:offset] : 0
        if limit = options[:limit]
          sql =sql.sub!(/SELECT/i,"SELECT TOP #{sanitize_limit(limit+offset)}")
        end
        sql
      end
    
      def sanitize_limit(limit)
        if limit.to_s =~ /,/
          limit.to_s.split(',').map{ |i| i.to_i }.join(',')
        else
          limit.to_i
        end
      end

    end
  end
end

module ActiveRecord
  class Migrator
    extend JdbcSpec::ActiveRecordExtensions
    class << self
   
      alias_method :original_get_all_versions, :get_all_versions

      def get_all_versions
        Base.table_name_prefix = "PUB."
        res = method(:original_get_all_versions).call
        Base.table_name_prefix = ""
        res
      end
    end

    alias_method :original_record_version_state_after_migrating, :record_version_state_after_migrating

    def record_version_state_after_migrating(version)
      Base.table_name_prefix = "PUB."
      res = method(:original_record_version_state_after_migrating).call(version)
      Base.table_name_prefix = ""
      res
    end
    
  end

  class Base
    extend JdbcSpec::ActiveRecordExtensions

    def attributes_from_column_definition
      self.class.columns.inject({}) do |attributes, column|
        next(attributes) if column.from_extended_column?
        attributes[column.name] = column.extended? ? extended_default(column) : common_default(column)
        attributes
      end
    end
    
    private
    def extended_default(column)
      [nil]+(1..column.extended_size).map {column.default}
    end

    def common_default(column)
     
      return nil if (column.default=="NULL")
      column.default unless column.name == self.class.primary_key
    end
    
    class << self
      # Les méthodes find sont réimplémentées pour :
      # 1 - Gérer la récupération des champs extend de Progress
      # 2 - Gérer l'option :offset qui n'existe pas en SQL Progress
   
      
      #Test si déjà défini car lorsque les tests sont lancés avec rake , deux fois évalué ... donc boucle
      alias_method :original_find, :find unless ActiveRecord::Base.methods.include?('original_find')

      def find(*args)
        @offset_find_opt = args.dup.extract_options![:offset]
        extend_objects original_find(*args)
      end
    
      def find_by_sql(sql)
        records = connection.select_all(sanitize_sql(sql), "#{name} Load")
        last =  @offset_find_opt ?  @offset_find_opt : 0
        (1..last).each{records.shift} #can be replaced with drop in ruby 1.9
        records.collect! { |record| instantiate(record) }
      end

      private
      
      #Transforme les champs extend Progress en Array
      def extend_objects(objects)
        return objects if  objects.is_a?(Array) && objects.empty?
        return objects if objects.nil?
        objs = objects.is_a?(Array) ? objects : [objects]
        objs.each do |obj|
          obj.attributes.each do |attr|
            column =  columns_hash[attr[0]]
            obj[attr[0]] = [nil]+attr[1].split(';',column.extended_size)  if column.extended?
          end
        end
        objects
      end
    end
    
  end
end

