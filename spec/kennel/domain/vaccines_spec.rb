# frozen_string_literal: true

RSpec.describe Kennel::Domain::Vaccines do
  describe '.legally_required?' do
    it '狂犬病は true を返すこと' do
      expect(described_class.legally_required?(:rabies)).to be(true)
    end

    it '法定でないワクチンは false を返すこと' do
      expect(described_class.legally_required?(:kennel_cough)).to be(false)
    end
  end
end
