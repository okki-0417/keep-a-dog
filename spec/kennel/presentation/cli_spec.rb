# frozen_string_literal: true

require 'stringio'

RSpec.describe Kennel::Presentation::CLI do
  let(:container) { Kennel::Composition::Container.new }
  let(:out) { StringIO.new }
  subject(:cli) { described_class.new(container: container, out: out) }

  def run(*argv)
    cli.run(argv)
  end

  describe '#run' do
    it 'adopt で犬を迎え、犬種と状態が表示されること' do
      code = run('adopt', '--breed', 'shiba', '--age', '60')
      expect([code, out.string.include?('柴犬')]).to eq([0, true])
    end

    it 'status で迎えた犬の状態が表示されること' do
      run('adopt', '--breed', 'chihuahua')
      out.truncate(0) && out.rewind
      run('status')
      expect(out.string).to include('チワワ', '体型スコア')
    end

    it 'live で1日進み、状態が更新されて表示されること' do
      run('adopt', '--breed', 'shiba', '--age', '400')
      run('live', '--kcal', '0')
      expect(out.string).to include('1日が過ぎた')
    end

    it '犬がいない状態で status するとエラーで終了コード1を返すこと' do
      expect([run('status'), out.string.include?('まだ犬がいません')]).to eq([1, true])
    end

    it '未知のコマンドはエラーで終了コード1を返すこと' do
      expect([run('frolic'), out.string.include?('未知のコマンド')]).to eq([1, true])
    end

    it 'train で号令と場所を指定してしつけられること' do
      run('adopt', '--breed', 'chihuahua', '--age', '400')
      run('train', '--cue', 'sit', '--context', 'kitchen')
      expect(out.string).to include('kitchenで sit を練習した')
    end

    it 'treat で治療したことが表示されること' do
      run('adopt', '--breed', 'shiba', '--age', '400')
      run('treat')
      expect(out.string).to include('治療した')
    end

    it 'help で使い方が表示されること' do
      run('help')
      expect(out.string).to include('使い方')
    end
  end
end
