# Offset pagination without a gem.
#   records, meta = paginate(Todo.all)
#   meta => { page: 2, per_page: 10, total_count: 42, total_pages: 5 }
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
