# frozen_string_literal: true

require 'tty-box'
require 'pastel'

module Kennel
  module Presentation
    # 犬の姿(DogArt)とゲージ・注意サイン(DogView)・行動の記録(日誌)を枠に並べて描く。
    module Dashboard
      ART_WIDTH = 14
      DIARY_LINES = 6
      # tty-box は全角・絵文字の表示幅を取り違えて折り返すため、枠幅を明示して分断を防ぐ。
      PANEL_WIDTH = 60

      module_function

      def render(dog:, diary: [], pastel: Pastel.new, notice: nil)
        [
          notice && pastel.yellow("⚠ #{notice}"),
          dog_panel(dog, pastel),
          diary_panel(diary)
        ].compact.join("\n")
      end

      def dog_panel(dog, pastel)
        rows = side_by_side(DogArt.for(dog).split("\n"), DogView.gauges(dog))
        flags = DogView.flags(dog).map { |flag| pastel.yellow("• #{flag}") }
        content = (rows + [''] + flags).join("\n")
        TTY::Box.frame(content, title: { top_left: " #{pastel.bold(DogView.headline(dog))} " }, width: PANEL_WIDTH, padding: [0, 1])
      end

      def diary_panel(diary)
        entries = diary.last(DIARY_LINES).map { |entry| "・#{entry}" }
        entries = ['(まだ記録なし)'] if entries.empty?
        TTY::Box.frame(entries.join("\n"), title: { top_left: ' 日誌 ' }, width: PANEL_WIDTH, padding: [0, 1])
      end

      def side_by_side(left, right)
        Array.new([left.size, right.size].max) do |i|
          "#{(left[i] || '').ljust(ART_WIDTH)}  #{right[i]}".rstrip
        end
      end
    end
  end
end
