module ActiveRecord
  module ConnectionAdapters

    class TableDefinition

      alias_method :original_column, :column unless ActiveRecord::ConnectionAdapters::TableDefinition.instance_methods.include?('original_column')
    
      def column(name, type, options = {})
        method(:original_column).call(name,type,options)
        column = self[name]
        column.cs = options[:cs]
        self
      end
    end
    
    class ColumnDefinition 
      attr_accessor :cs

      alias_method :original_to_sql, :to_sql unless ActiveRecord::ConnectionAdapters::ColumnDefinition.instance_methods.include?('original_to_sql')
 
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
          :decimal     => { :name => "DECIMAL(32,10)"},
          :datetime    => { :name => "TIMESTAMP" },
          :timestamp   => { :name => "TIMESTAMP WITH TIME ZONE" },
          :time        => { :name => "DATETIME" },
          :date        => { :name => "DATE" },
          :binary      => { :name => "LVARBINARY", :limit => 104857600 },
          :boolean     =>{ :name => "BIT" } 
        }
      end
    
      def indexes(table_name, name = nil)
        indexes_from_sysprogress_sysindexes(table_name).map do |index|
          IndexDefinition.new(table_name,index[:name],index[:unique],index[:columns])
        end
      end

      private
      def indexes_from_sysprogress_sysindexes(table)
        indexes=[]
        sql = "select idxname,colname from sysprogress.sysindexes where tbl='#{table}'"
        select_all(sql).each do |index|
          r_idx = indexes.select{|idx| idx[:name] == index['idxname']}
          if r_idx.empty?
            indexes << {:name => index['idxname'], :columns => [index['colname']], :unique => unique?(index['idxname'],table)}
          else
            r_idx[0][:columns]<< index['colname']
          end
        end
        indexes
      end

      def table_rowid(table)
        sql = 'select rowid from pub."_File" where "_File-Name" ='+"'#{table}'";
        select_one(sql);
      end

      def unique? (index_name,table_name)
        rowid = table_rowid(table_name)
        sql = 'select "_Unique" from "pub"."_Index" where "_Index-name"='+"'#{index_name}' and "+'"_File-recid"='+"'"+rowid['rowid'].to_s+"'";
        res = select_one(sql)
        res['_unique'].to_i == 1 ? true : false
      end

    end

    class JdbcColumn < Column

     
      def simplified_type(field_type)
        case field_type
        when /^bigint/i             then :integer
        when /^date/i               then :date
        when /^timestamp_timezone/  then :timestamp
        when /^timestamp/i          then :datetime
        when /^numeric/i            then :decimal  
        when /^bit\(1\)$/i          then :boolean
        when /^lvarbinary/i         then :binary
        when /^varchar/i            then :string
        when /^integer/i            then :integer
        when /^lvarchar/i           then :text
        when /^varbinary/i          then :binary
        else                         :binary  #RECID and ROWID
        end
      end

      def type_cast(value)
        return nil if value == 'NULL'
        return 'NULL' if value.nil?
        super
      end

      def extended=(ext)
        @extended = ext
      end

      def extended?
        @extended
      end

      def from_extended_column= (val)
        @from_extended_column = val
      end

      def from_extended_column?
        @from_extended_column
      end

      def extended_size=(val)
        @extended_size = val
      end

      def extended_size
        @extended_size
      end

      def case_sensitive=(val)
        @case_sensitive = val
      end

      def case_sensitive?
        @case_sensitive
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

      alias_method :original_add_column, :add_column
      alias_method :original_remove_index, :remove_index
      alias_method :original_add_column_options!, :add_column_options! unless ActiveRecord::ConnectionAdapters::SchemaStatements.instance_methods.include?('original_add_column_options!')

      def add_column_options!(sql, options)
        method(:original_add_column_options!).call(sql,options)
        if options.include?(:cs)
          case_s = options[:cs]? 'y' : 'n'
          sql << " pro_case_sensitive '#{case_s}'"
        end
      end
      
      def table_exists?(table_name)
        table = table_name.dup.gsub("pub.","")
        tables.include?(table.to_s)
      end

      def add_column(table_name, column_name, type, options = {})
        options[:cs]= false if (!options[:cs] && type.to_s == 'string')
        method(:original_add_column).call(table_name, column_name, type, options)
      end
      
      def remove_index(table_name, options = {})
        table = table_name.include?('.') ? table_name : 'pub.'+table_name
        method(:original_remove_index).call(table,options)
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

