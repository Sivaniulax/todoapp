require "rails_helper"

RSpec.describe HexColorValidator do
  # A throwaway ActiveModel class, so the validator is tested on its own
  # rather than through Category.
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :color

      validates :color, hex_color: true

      def self.name = "Swatch"
    end
  end

  it "accepts a six digit hex color" do
    expect(model_class.new(color: "#6366f1")).to be_valid
  end

  it "rejects names, short hex and missing values" do
    [ "red", "#fff", "6366f1", "", nil ].each do |value|
      record = model_class.new(color: value)
      expect(record).not_to be_valid, "expected #{value.inspect} to be rejected"
      expect(record.errors[:color]).to include("must be a hex color like #6366f1")
    end
  end
end
