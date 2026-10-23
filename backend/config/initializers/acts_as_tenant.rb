# Tenancy is enforced in the controllers: ApplicationController sets the
# workspace for every authenticated request, so no request runs unscoped.
# Jobs and the admin dashboard cross workspaces on purpose and have to say
# so with ActsAsTenant.without_tenant or with_tenant.
ActsAsTenant.configure do |config|
  config.require_tenant = false
end
