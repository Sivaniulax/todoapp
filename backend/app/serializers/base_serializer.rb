# Plain-Ruby serializers: explicit about which fields leave the API,
# so we never leak things like password_digest.
class BaseSerializer
  def self.many(records)
    records.map { |record| new(record).as_json }
  end

  attr_reader :record

  def initialize(record)
    @record = record
  end
end
