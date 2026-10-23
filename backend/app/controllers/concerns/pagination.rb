# Offset pagination, no gem needed.
#   records, meta = paginate(Todo.all)
module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

  private

  def paginate(scope)
    per_page = params[:per_page].to_i
    per_page = DEFAULT_PER_PAGE unless per_page.positive?
    per_page = [ per_page, MAX_PER_PAGE ].min
    page = [ params[:page].to_i, 1 ].max

    total_count = scope.count
    total_pages = [ (total_count / per_page.to_f).ceil, 1 ].max

    records = scope.offset((page - 1) * per_page).limit(per_page)
    [ records, { page:, per_page:, total_count:, total_pages: } ]
  end
end
