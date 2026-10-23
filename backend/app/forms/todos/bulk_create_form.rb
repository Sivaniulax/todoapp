module Todos
  # Validates the pasted text and writes every todo in one transaction.
  # Has no table of its own.
  #
  #   form = Todos::BulkCreateForm.new(current_user, titles_text: "a\nb")
  #   form.save   # => true, form.todos => [ #<Todo a>, #<Todo b> ]
  class BulkCreateForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    MAX_TODOS = 50

    attribute :titles_text, :string
    attribute :priority, :string, default: "medium"
    attribute :category_id, :integer
    attribute :due_date, :date

    validates :titles_text, presence: true
    validates :priority, inclusion: { in: ->(_form) { Todo.priorities.keys } }
    validate :not_too_many

    attr_reader :todos

    def initialize(user, attributes = {})
      @user = user
      @todos = []
      super(attributes)
    end

    # One title per line, blanks ignored.
    def titles
      titles_text.to_s.split("\n").filter_map { |line| line.squish.presence }
    end

    def save
      return false if invalid?

      # All or nothing: one bad title rolls the whole batch back.
      ApplicationRecord.transaction do
        @todos = titles.map do |title|
          user.todos.create!(title:, priority:, category_id:, due_date:)
        end
      end
      true
    rescue ActiveRecord::RecordInvalid => error
      errors.merge!(error.record)
      @todos = []
      false
    end

    private

    attr_reader :user

    def not_too_many
      return if titles.size <= MAX_TODOS

      errors.add(:titles_text, "cannot contain more than #{MAX_TODOS} todos at once")
    end
  end
end
