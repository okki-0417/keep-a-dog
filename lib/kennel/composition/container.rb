# frozen_string_literal: true

module Kennel
  module Composition
    class Container
      attr_reader :dogs

      def self.sqlite(path: ':memory:')
        db = Infrastructure::Persistence::Sqlite.connect(path)
        new(dogs: Infrastructure::Persistence::SqliteDogRepository.new(db))
      end

      def initialize(dogs: nil)
        @dogs = dogs || Infrastructure::Persistence::InMemoryDogRepository.new
      end

      def adopt_dog
        Application::Services::AdoptDog.new(dogs: @dogs)
      end

      def train_dog
        Application::Services::TrainDog.new(dogs: @dogs)
      end

      def treat_dog
        Application::Services::TreatDog.new(dogs: @dogs)
      end

      def feed_dog
        Application::Services::FeedDog.new(dogs: @dogs)
      end

      def give_water
        Application::Services::GiveWater.new(dogs: @dogs)
      end

      def walk_dog
        Application::Services::WalkDog.new(dogs: @dogs)
      end

      def socialize_dog
        Application::Services::SocializeDog.new(dogs: @dogs)
      end

      def praise_dog
        Application::Services::PraiseDog.new(dogs: @dogs)
      end

      def brush_teeth
        Application::Services::BrushTeeth.new(dogs: @dogs)
      end

      def vaccinate_dog
        Application::Services::VaccinateDog.new(dogs: @dogs)
      end

      def neuter_dog
        Application::Services::NeuterDog.new(dogs: @dogs)
      end

      def live_a_day
        Application::Services::LiveADay.new(dogs: @dogs)
      end
    end
  end
end
