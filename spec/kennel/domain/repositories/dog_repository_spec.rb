# frozen_string_literal: true

RSpec.describe Kennel::Domain::Repositories::DogRepository do
  subject(:port) { Class.new { include Kennel::Domain::Repositories::DogRepository }.new }

  describe 'インターフェース契約' do
    it '未実装の find / save / delete は NotImplementedError を投げること' do
      expect { port.find('x') }.to raise_error(NotImplementedError)
      expect { port.save(Object.new) }.to raise_error(NotImplementedError)
      expect { port.delete('x') }.to raise_error(NotImplementedError)
    end
  end
end
