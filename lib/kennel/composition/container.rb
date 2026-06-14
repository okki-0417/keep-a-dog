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

      def live_a_day
        Application::Services::LiveADay.new(dogs: @dogs)
      end
    end
  end
end
