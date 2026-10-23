class TagResource
  include Alba::Resource

  attributes :id, :name

  attribute :todos_count do |tag|
    tag.taggings.size
  end
end
