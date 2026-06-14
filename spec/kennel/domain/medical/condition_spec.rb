# frozen_string_literal: true

RSpec.describe Kennel::Domain::Medical::Condition do
  describe '#chronic? / #acute?' do
    it '慢性フラグに応じて互いに排他で返すこと' do
      chronic = described_class.new(key: :x, name: '慢性', chronic: true)
      acute = described_class.new(key: :y, name: '急性', chronic: false)
      expect([chronic.chronic?, chronic.acute?, acute.chronic?, acute.acute?])
        .to eq([true, false, false, true])
    end
  end
end
