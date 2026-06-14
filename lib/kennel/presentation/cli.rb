# frozen_string_literal: true

module Kennel
  module Presentation
    class CLI
      def initialize(container:, out: $stdout)
        @container = container
        @out = out
      end

      def run(argv)
        command, *args = argv
        dispatch(command, args)
        0
      rescue ArgumentError, Application::Errors::ApplicationError => e
        @out.puts "エラー: #{e.message}"
        1
      end

      private

      def dispatch(command, args)
        case command
        when 'adopt'                then adopt(args)
        when 'status', nil          then status
        when 'train'                then train(args)
        when 'treat'                then treat
        when 'live'                 then live(args)
        when 'help', '--help', '-h' then help
        else raise ArgumentError, "未知のコマンド: #{command}(help を参照)"
        end
      end

      def adopt(args)
        opts = parse(args)
        dog = @container.adopt_dog.call(
          Application::Commands::AdoptDogCommand.new(breed_key: fetch(opts, 'breed').to_sym, age_in_days: (opts['age'] || '0').to_i)
        )
        @out.puts "#{dog.breed.name}を迎えました。"
        @out.puts DogView.render(dog)
      end

      def status
        @out.puts DogView.render(current_dog)
      end

      def train(args)
        opts = parse(args)
        cue = fetch(opts, 'cue')
        context = fetch(opts, 'context')
        @container.train_dog.call(
          Application::Commands::TrainDogCommand.new(dog_id: current_dog.id, cue: cue.to_sym, context: context.to_sym)
        )
        @out.puts "#{context}で #{cue} を練習した"
      end

      def treat
        @container.treat_dog.call(Application::Commands::TreatDogCommand.new(dog_id: current_dog.id))
        @out.puts '治療した'
        @out.puts DogView.render(current_dog)
      end

      def live(args)
        kcal = (parse(args)['kcal'] || '0').to_i
        @container.live_a_day.call(Application::Commands::LiveADayCommand.new(dog_id: current_dog.id, intake_kcal: kcal))
        @out.puts '1日が過ぎた'
        @out.puts DogView.render(current_dog)
      end

      def help
        @out.puts <<~HELP
          使い方: kennel <コマンド>
            adopt --breed <犬種> [--age <日齢>]   犬を迎える
            status                                状態を見る
            train --cue <号令> --context <場所>   しつける
            treat                                 治療する
            live [--kcal <摂取カロリー>]          1日進める
        HELP
      end

      def current_dog
        @container.dogs.all.first || raise(ArgumentError, 'まだ犬がいません。adopt で迎えてください')
      end

      def parse(args)
        args.each_slice(2).each_with_object({}) do |(key, value), opts|
          opts[key.sub(/\A--/, '')] = value if key&.start_with?('--')
        end
      end

      def fetch(opts, key)
        opts.fetch(key) { raise ArgumentError, "--#{key} を指定してください" }
      end
    end
  end
end
