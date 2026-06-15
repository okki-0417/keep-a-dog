# frozen_string_literal: true

require 'tty-prompt'
require 'pastel'

module Kennel
  module Presentation
    # 対話的に一匹の犬を世話する画面。ドメインの豊かさ(ごはん・水・運動・社会化・しつけ・
    # 予防接種・去勢・治療…)をメニューから選べるようにし、結果をダッシュボードに映す。
    class TUI
      MENU = {
        '🍖 ごはん'      => :feed,
        '💧 水をあげる'  => :water,
        '🦴 散歩'        => :walk,
        '🤝 社会化'      => :socialize,
        '🤚 なでる'      => :praise,
        '🪥 歯みがき'    => :brush,
        '🎓 しつけ'      => :train,
        '💉 ワクチン'    => :vaccinate,
        '✂️  去勢・避妊'  => :neuter,
        '💊 治療'        => :treat,
        '🌅 1日すごす'   => :advance,
        '👋 おわる'      => :quit
      }.freeze

      BREEDS = Domain::Breed::BreedCatalog::DEFINITIONS.to_h { |key, attrs| [attrs[:name], key] }.freeze
      AGES = { '子犬(生後60日)' => 60, '成犬(2歳)' => 730 }.freeze
      PORTIONS = { '少なめ' => [20, false], 'ふつう' => [40, false], 'がっつり(早食い)' => [60, true] }.freeze
      WALK_MINUTES = { '15分' => 15, '30分' => 30, '1時間' => 60 }.freeze
      RATIONS = { '控えめ' => 0.7, '適量' => 1.0, 'たっぷり' => 1.4 }.freeze
      CUES = { 'おすわり' => :sit, 'ふせ' => :down, 'まて' => :stay, 'おいで' => :come }.freeze
      CONTEXTS = { '家の中' => :kitchen, '公園' => :park, '街なか' => :street }.freeze
      DISEASES = { '狂犬病' => :rabies, 'ジステンパー' => :distemper, 'パルボ' => :parvovirus, 'レプトスピラ' => :leptospirosis }.freeze

      def initialize(container:, prompt: TTY::Prompt.new, out: $stdout, pastel: Pastel.new)
        @container = container
        @prompt = prompt
        @out = out
        @pastel = pastel
        @diary = []
        @notice = nil
      end

      def run
        adopt_flow if @container.dogs.all.empty?

        loop do
          dog = current_dog
          render(dog)
          choice = choose('どうする?', menu_for(dog))
          break if choice == :quit

          act(choice, dog)
        end
        @out.puts 'またね 🐾'
      end

      private

      def adopt_flow
        @out.puts 'ようこそ。新しい家族を迎えましょう。'
        breed_key = choose('犬種を選ぶ', BREEDS)
        age = choose('迎えるときの年齢', AGES)
        @container.adopt_dog.call(Application::Commands::AdoptDogCommand.new(breed_key: breed_key, age_in_days: age))
      end

      def act(choice, dog)
        case choice
        when :feed      then feed(dog)
        when :water     then run_use_case(:give_water, Application::Commands::GiveWaterCommand.new(dog_id: dog.id), '水をあげた')
        when :walk      then walk(dog)
        when :socialize then run_use_case(:socialize_dog, Application::Commands::SocializeDogCommand.new(dog_id: dog.id), '社会化の体験をした')
        when :praise    then run_use_case(:praise_dog, Application::Commands::PraiseDogCommand.new(dog_id: dog.id), 'なでてほめた')
        when :brush     then run_use_case(:brush_teeth, Application::Commands::BrushTeethCommand.new(dog_id: dog.id), '歯みがきをした')
        when :train     then train(dog)
        when :vaccinate then vaccinate(dog)
        when :neuter    then run_use_case(:neuter_dog, Application::Commands::NeuterDogCommand.new(dog_id: dog.id), '去勢・避妊をした')
        when :treat     then run_use_case(:treat_dog, Application::Commands::TreatDogCommand.new(dog_id: dog.id), '治療を受けた')
        when :advance   then advance(dog)
        end
      end

      def feed(dog)
        satiety, gulped = choose('どれくらい?', PORTIONS)
        run_use_case(:feed_dog, Application::Commands::FeedDogCommand.new(dog_id: dog.id, satiety: satiety, gulped: gulped),
                     "ごはんをあげた#{gulped ? '(早食い…)' : ''}")
      end

      def walk(dog)
        minutes = choose('どれくらい歩く?', WALK_MINUTES)
        run_use_case(:walk_dog, Application::Commands::WalkDogCommand.new(dog_id: dog.id, minutes: minutes), "散歩 #{minutes}分")
      end

      def train(dog)
        cue = choose('号令を選ぶ', CUES)
        context = choose('どこで?', CONTEXTS)
        run_use_case(:train_dog, Application::Commands::TrainDogCommand.new(dog_id: dog.id, cue: cue, context: context),
                     "しつけ: #{cue}")
      end

      def vaccinate(dog)
        disease = choose('どのワクチン?', DISEASES)
        run_use_case(:vaccinate_dog, Application::Commands::VaccinateDogCommand.new(dog_id: dog.id, disease: disease),
                     "ワクチン接種: #{disease}")
      end

      def advance(dog)
        factor = choose('今日のごはんの量は?', RATIONS)
        intake = (dog.maintenance_energy_requirement * factor).round
        run_use_case(:live_a_day, Application::Commands::LiveADayCommand.new(dog_id: dog.id, intake_kcal: intake), '1日がすぎた')
      end

      # 選択肢が一画面に収まるよう、ページングせず全項目を表示する(per_page を項目数に合わせる)。
      def choose(question, choices)
        @prompt.select(question, choices, per_page: choices.size, cycle: true)
      end

      def run_use_case(name, command, note)
        @container.public_send(name).call(command)
        @diary << note
      rescue Application::Errors::ApplicationError => e
        @notice = e.message
      end

      def render(dog)
        @out.print "\e[2J\e[H"
        @out.puts Dashboard.render(dog: dog, diary: @diary, pastel: @pastel, notice: @notice)
        @notice = nil
      end

      def menu_for(dog)
        dog.dead? ? { '🕊 見送る' => :quit } : MENU
      end

      def current_dog
        @container.dogs.all.first
      end
    end
  end
end
