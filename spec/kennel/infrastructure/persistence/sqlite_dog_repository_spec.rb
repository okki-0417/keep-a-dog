# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Kennel::Infrastructure::Persistence::SqliteDogRepository do
  let(:db) { Kennel::Infrastructure::Persistence::Sqlite.connect }
  subject(:repository) { described_class.new(db) }

  def rich_dog
    dog = Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:shiba), age_in_days: 400)
    dog.get_hungrier(30)
    dog.reassure
    5.times { dog.train(:sit, :kitchen) }
    dog.fall_ill(Kennel::Domain::Medical::ConditionCatalog.fetch(:atopy))
    dog.neglect_dental_care(40)
    dog.left_alone(6)
    2.times { dog.vaccinate(:distemper) }
    dog.neuter
    dog.experience_pain(40)
    dog.scary_experience
    dog.exercise(20)
    dog.lose_water(30)
    dog
  end

  def deep_chested_dog
    dog = Kennel::Domain::Dog.new(breed: Kennel::Domain::Breed::BreedCatalog.fetch(:saint_bernard), age_in_days: 400)
    dog.bolt_large_meal
    dog
  end

  describe '#save / #find' do
    it '豊富に状態を変えた犬を保存して読み戻すと全状態が一致すること' do
      dog = rich_dog
      repository.save(dog)
      expect(repository.find(dog.id).to_snapshot).to eq(dog.to_snapshot)
    end

    it '胃捻転の急性リスクなど真偽の状態も往復で保たれること' do
      dog = deep_chested_dog
      repository.save(dog)
      expect(repository.find(dog.id).at_acute_bloat_risk?).to be(true)
    end

    it '存在しない id では nil を返すこと' do
      expect(repository.find('missing')).to be_nil
    end
  end

  describe '関係マッピング(BLOBではなく列・子テーブル)' do
    it '習得した芸が dog_training 子テーブルの行になること' do
      dog = rich_dog
      repository.save(dog)
      count = db.get_first_value('SELECT COUNT(*) FROM dog_training WHERE dog_id = ?', [dog.id])
      expect(count).to eq(1)
    end
  end

  describe '#all' do
    it '保存した全頭を読み戻せること' do
      repository.save(rich_dog)
      repository.save(deep_chested_dog)
      expect(repository.all.size).to eq(2)
    end
  end

  describe '保存のアトミック性' do
    it '子テーブルの挿入が失敗すると、その保存全体が巻き戻ること(savepoint)' do
      dog = rich_dog
      allow(db).to receive(:execute).and_call_original
      allow(db).to receive(:execute).with(a_string_matching(/INSERT INTO dog_training/), anything).and_raise(SQLite3::Exception)
      expect { repository.save(dog) }.to raise_error(SQLite3::Exception)
      expect(repository.find(dog.id)).to be_nil
    end
  end

  describe '#delete' do
    it '削除すると親も子テーブルも消えること(外部キーで連鎖)' do
      dog = rich_dog
      repository.save(dog)
      repository.delete(dog.id)
      orphans = db.get_first_value('SELECT COUNT(*) FROM dog_training') + db.get_first_value('SELECT COUNT(*) FROM dog_conditions')
      expect([repository.find(dog.id), orphans]).to eq([nil, 0])
    end
  end

  describe '本当にファイルへ永続化されること' do
    it '別接続を開いても読み戻せること' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'kennel.db')
        dog = rich_dog
        described_class.new(Kennel::Infrastructure::Persistence::Sqlite.connect(path)).save(dog)
        reloaded = described_class.new(Kennel::Infrastructure::Persistence::Sqlite.connect(path)).find(dog.id)
        expect(reloaded.to_snapshot).to eq(dog.to_snapshot)
      end
    end
  end
end
