#   validates :color, hex_color: true
#
# The message lives in en.yml under activemodel.errors.messages.invalid_hex_color.
class HexColorValidator < ActiveModel::EachValidator
  FORMAT = /\A#\h{6}\z/

  def validate_each(record, attribute, value)
    return if value.present? && FORMAT.match?(value)

    record.errors.add(attribute, options.fetch(:message, :invalid_hex_color))
  end
end
