# frozen_string_literal: true

require 'stringio'

RSpec.describe Kennel::Presentation::TUI do
  let(:container) { Kennel::Composition::Container.new }
  let(:out) { StringIO.new }

  def run_with(answers)
    prompt = ScriptedPrompt.new(answers)
    described_class.new(container: container, prompt: prompt, out: out, pastel: Pastel.new(enabled: false)).run
  end

  def current_dog
    container.dogs.all.first
  end

  it '犬がいなければ迎えるフローから始まり、犬種と年齢で迎えること' do
    run_with([:shiba, 60, :quit])
    expect(current_dog.breed.name).to eq('柴犬')
  end

  it '迎えた犬のダッシュボードが描画されること' do
    run_with([:shiba, 60, :quit])
    expect(out.string).to include('柴犬', '空腹')
  end

  it '各メニューがユースケースを呼び、状態に反映されること' do
    run_with([
               :shiba, 730,           # 迎える(成犬)
               :water,                # 水
               :walk, 60,             # 散歩60分
               :socialize,            # 社会化
               :praise,               # なでる
               :brush,                # 歯みがき
               :feed, [40, false],    # ごはん
               :train, :sit, :kitchen, # しつけ
               :vaccinate, :rabies,   # ワクチン
               :neuter,               # 去勢
               :treat,                # 治療
               :advance, 1.0,         # 1日すごす
               :quit
             ])
    dog = current_dog
    expect([dog.well_exercised?, dog.neutered?, dog.immune_to?(:rabies)]).to eq([true, true, true])
  end

  it '行動が日誌に記録されること' do
    run_with([:shiba, 60, :praise, :quit])
    expect(out.string).to include('なでてほめた')
  end

  it 'ユースケースのエラーで落ちず、注意を表示して続行すること' do
    failing = Class.new do
      def call(_command)
        raise Kennel::Application::Errors::DogNotFound, 'その犬はいません'
      end
    end.new
    allow(container).to receive(:praise_dog).and_return(failing)
    run_with([:shiba, 60, :praise, :quit])
    expect(out.string).to include('⚠', 'その犬はいません')
  end

  it '亡くなった犬は見送りの姿になること' do
    container.adopt_dog.call(Kennel::Application::Commands::AdoptDogCommand.new(breed_key: :shiba, age_in_days: 60))
    dog = current_dog
    dog.pass_day(6_000)
    container.dogs.save(dog)
    run_with([:quit])
    expect(out.string).to include('旅立ち')
  end

  it '終わると別れの挨拶を表示すること' do
    run_with([:shiba, 60, :quit])
    expect(out.string).to include('またね')
  end
end
