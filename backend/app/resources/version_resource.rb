class VersionResource
  include Alba::Resource

  attributes :id, :event, :created_at

  # whodunnit is a string column by convention; we store user ids in it.
  attribute :user_id do |version|
    version.whodunnit&.to_i
  end

  # { "title" => ["old", "new"] }, trimmed to what actually moved.
  attribute :changes do |version|
    version.changeset.transform_values { |before, after| { from: before, to: after } }
  end
end
