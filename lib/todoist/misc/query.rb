# Exposes hidden API that allows queries to be issued to return items.  Queries
# are restricted to a single "type" of query that is related to priority or date.  
# When it cannot parse query, it either returns a date result for 
# today or occasionally a 500 error.

module Todoist
  module Misc
    class Query < Todoist::Service
        include Todoist::Util 

        # Given an array of queries, return multiple results with key being the 
        # query results.  Query results have three key elements:  query, type, 
        # and data.  Data is where the items are stored.
        def queries(queries)
          result = @api_helper.get_response(Config::TODOIST_QUERY_COMMAND, 
            queries: queries.to_json)
          return ParseHelper.make_objects_as_hash(result, "query")
        end
        
        # Given a query, return result.  See return structure in comments above.
        def query(query)
          result = queries([query])
          return result[query]
        end


    end
  end
end

