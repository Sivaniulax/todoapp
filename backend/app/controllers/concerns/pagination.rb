# Offset pagination through Pagy, keeping the meta shape the client expects.
#   records, meta = paginate(Todo.all)
module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

  included do
    include Pagy::Method
  end

  private

  def paginate(scope)
    # Pagy reads ?page= from the request and returns an empty last page
    # rather than raising when the client asks past the end.
    page, records = pagy(:offset, scope, limit: per_page)

    [ records, { page: page.page, per_page: page.limit, total_count: page.count, total_pages: page.last } ]
  end

  def per_page
    requested = params[:per_page].to_i
    requested.positive? ? [ requested, MAX_PER_PAGE ].min : DEFAULT_PER_PAGE
  end
end
