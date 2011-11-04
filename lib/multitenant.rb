require 'multitenant/schema_utils'

# Multitenant: making cross tenant data leaks a thing of the past...since 2011
module Multitenant
  class << self
    attr_accessor :current_tenant

    # execute a block scoped to the current tenant
    # unsets the current tenant after execution
    def with_tenant(tenant = nil, &block)
      previous_tenant = Multitenant.current_tenant
      Multitenant.current_tenant = tenant if tenant

      SchemaUtils.with_schema(Multitenant.current_tenant.schema_name) do
        yield
      end

    ensure
      Multitenant.current_tenant = previous_tenant
    end
  end
end