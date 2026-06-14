# frozen_string_literal: true

# TUI テスト用に、あらかじめ用意した回答を順に返す tty-prompt の代役。
# 実際の select は選択肢から値を返すが、ここでは台本の値をそのまま返す。
class ScriptedPrompt
  def initialize(answers)
    @answers = answers.dup
  end

  def select(_question, _choices = nil, **_options)
    @answers.shift
  end

  def ask(_question, **_options)
    @answers.shift
  end
end
