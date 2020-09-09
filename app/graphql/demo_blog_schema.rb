class DemoBlogSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST
  use GraphQL::Execution::Errors

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections

  rescue_from(ActiveRecord::RecordNotFound) do |error|
    raise GraphQL::ExecutionError, error.message
  end
end
