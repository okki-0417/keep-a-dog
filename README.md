# keep-a-dog

犬一匹の飼育をドメインにした、**DDD・レイヤードアーキテクチャ**のサンプルコード。

「素人の思いつき(フォークモデル)」ではなく、**獣医・育種・行動学の専門家ならではのドメイン知識**を、
テストとしてルールに落とし込むことを主題にしている。

## このプロジェクトの主題

- **専門知識をルールにする** — 「犬の年齢は人間換算×7」ではなく対数的、「成熟」は性成熟・骨格成熟・
  社会的成熟に分かれる、罰は信頼を損なう、犬は痛みを隠す…といった、専門家が当然知っている知識を
  ドメインモデルの振る舞いとして表現する。
- **テストが設計書を兼ねる** — テストファーストで、テストの構造そのものが読んでドメインが分かる
  「仕様書」になるように書く。

```console
$ bundle exec rspec spec/knowledge --format doc

ライフステージと加齢
  3つの成熟(性成熟・骨格成熟・社会的成熟)
    大型犬は性成熟を迎えても骨格はまだ成長途中
      セントバーナードは生後600日で性成熟していても骨格は未成熟であること
  人間に換算した年齢
    生後1年の犬
      人間でいう約31歳に相当すること(俗説の×7=7歳ではない)
...
```

## テストの2層

| 層 | 置き場所 | 役割 | describe |
| --- | --- | --- | --- |
| **ドメイン知識(設計書)** | `spec/knowledge/` | ルールが正しくモデル化されているか | `'<ドメイン知識>'`(状況→帰結) |
| **単体テスト(保証)** | `spec/kennel/` | 境界・クランプ・不正入力・契約などの堅牢性 | `Class` / `#method` |

実装より先に設計書(知識テスト)を書いて設計を駆動し、その結果のコードに対して単体テストを書く。
単体テストは **行カバレッジ100%**。全185例。

## ドメイン知識(18単位)

ライフステージと加齢 / エネルギー収支 / 空腹と満腹 / 体温調節 / 学習と般化 / 社会化(と恐怖期) /
情動と愛着 / 健康と病気 / 感覚 / 歯と口腔 / 被毛と換毛 / 睡眠と休息 / ワクチンと予防接種 /
問題行動(分離不安) / 生殖ステータス(去勢・避妊) / 痛みを隠す / 運動の必要量 / 水分と脱水

## アーキテクチャ

```
lib/kennel/
├── domain/          集約 Dog・値オブジェクト・Breed/Condition・リポジトリのポート
├── application/     ユースケース(AdoptDog/TrainDog/TreatDog/LiveADay)・コマンド
├── infrastructure/  in-memory / SQLite アダプタ(関係マッピング＋メメント)
├── presentation/    CLI・状態表示(DogView)
└── composition/     Container(in-memory ↔ SQLite を差し替え)
```

- アプリ層は `Domain::Repositories::DogRepository` ポートだけに依存し、`Container` / `Container.sqlite` で
  実体を差し替えられる。
- SQLite アダプタは集約を BLOB に押し込まず、**列と子テーブルに関係マッピング**する。集約は不変条件を
  守るためセッターを持たないので、**メメント**(`Dog#to_snapshot` / `.from_snapshot`)で復元する。

## 動かす

Ruby 3.3 / Bundler。

```console
$ bundle install
$ bin/test                                       # 全テスト
$ bundle exec rspec spec/knowledge --format doc  # 設計書として読む
```

CLI(状態は SQLite に保存され、コマンドをまたいで犬が生き続ける):

```console
$ bin/kennel adopt --breed shiba --age 60
$ bin/kennel train --cue sit --context kitchen
$ bin/kennel live --kcal 300
$ bin/kennel status
🐕 柴犬  子犬  人間換算 約2歳
  体重 9.0kg  体型スコア 5/9
  空腹 40/100   信頼 50/100
  社会化 0/100
  健康 良好
```
