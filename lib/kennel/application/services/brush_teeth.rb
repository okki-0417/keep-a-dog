# frozen_string_literal: true

module Kennel
  module Application
    module Services
      class BrushTeeth < CommandHandler
        def call(command)
          dog = load!(command.dog_id)
          dog.brush_teeth
          @dogs.save(dog)
        end
      end
    end
  end
end
