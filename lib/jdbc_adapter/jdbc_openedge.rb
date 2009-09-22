module ::JdbcSpec

  module ActiveRecordExtensions

    def openedge_connection(config)
      config[:url] ||= "jdbc:datadirect:openedge://#{config[:host]}:#{config[:port]};databaseName=#{config[:database]}"
      config[:driver] ||= "com.ddtek.jdbc.openedge.OpenEdgeDriver"
      jdbc_connection(config)
    end

  end
  
 
  module OpenEdge

    DEFAULT_TABLE_PREFIX = 'pub'

    def add_column_options!(sql, options)
      super
      if options.include?(:cs)
        cs = options[:cs]? 'y' : 'n'
        sql << " pro_case_sensitive '#{cs}'"
      end
    end
    
    def quote(value, column = nil)

      if column
        if column.respond_to?(:extended) && column.extended?
          val = value.dup
          val.shift
          return "'"+val.join(";")+"'"
        end

        case column.type
        when :date,:datetime,:timestamp then return value.nil? ? "NULL" : value
        when :boolean                   then return value ? '1' : '0'
        when :string                    then return "'"+double_quotes(value)+"'"
        when :integer                   then return value.nil? ?  "NULL" :  value
        end
      end
      return value if value.kind_of?(Numeric)
      return value ? '1' : '0' if (value.kind_of?(TrueClass)|| value.kind_of?(FalseClass))
      return value.nil? ?  "NULL" :  "'"+value+"'"
    end
    
    def self.adapter_matcher(name,*)
      name =~ /openedge/i ? self : false
    end

    def quote_column_name(name)
      "\"#{name}\""
    end

    def quote_table_name(name)
      prefix, suffix = name.split(".")[0],name.split(".")[1]
      suffix ? '"'+prefix+'"."'+suffix+'"' : '"'+DEFAULT_TABLE_PREFIX+'"."'+prefix+'"'
    end

    def prefetch_primary_key?(table_name = nil)
      true
    end

    def next_sequence_value(sequence_name='dummy_sequence')
      sql = "select pub.dummy_sequence.nextval from pub.dummy_sequence"
      begin
        res = select_one(sql)
      rescue
        begin
          create_dummy_sequence
          return next_sequence_value
        rescue
          raise "Progress adaptor need dummy_seq table with one row for sequences. Unable to create it"
        end
      end
      raise "Unable to get nextval from DummySEQ" if res.nil?
      res['sequence_next'].to_i
    end
 
    def default_sequence_name(table, column = nil)
      "dummy_sequence"
    end

    def extended_columns(table)
      table = table.split('.')[1] if table.include?('.')
      sql = "select col,width,array_extent,coltype,col_subtype,dflt_value from sysprogress.syscolumns_full where tbl='#{table}'";
      select_all(sql).delete_if do |col|
        col['array_extent'] == 0
      end
    end

    def retrieve_extended_columns(columns,table_name)
      extended_columns(table_name).map do |ext_col|
        columns.each  do|col|
          if ext_col['col'] == col.name
            col.extended(true)
            col.extended_size = ext_col['array_extent']
          end
        end
        
      end
      columns
    end
 
    def columns(table_name, name=nil)
      cols = @connection.columns_internal(table_name, name)
      retrieve_extended_columns(cols,table_name)
    end

    private
     
    def create_dummy_sequence
      sql_create_table = "create table pub.DUMMY_SEQUENCE (id integer)"
      sql_insert_row = "insert into PUB.DUMMY_SEQUENCE(id) values(1)"
      sql_create_sequence = "create sequence pub.dummy_sequence increment by 1, start with 0, nomaxvalue, cycle"
      [sql_create_table, sql_insert_row, sql_create_sequence].each {|sql| @connection.execute_update(sql)}
    end
   
    def double_quotes(string)
      string.gsub("'","''")
    end
   
  end
  
end




