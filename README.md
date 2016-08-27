# なにこれ

面倒なRailsアプリ開発環境の構築が簡単にできます。

# どうなってんの

VagrantでUbuntuを起動し、その中でDockerを稼働させています。

# 事前準備

[VirtualBox](https://www.virtualbox.org/wiki/Downloads)と[Vagrant](https://www.vagrantup.com/downloads.html)をインストールします。

# 導入

## 既存のRailsアプリがある場合
* このリポジトリをcloneします。
* cloneした中身(README.mdと.git以外)をアプリのディレクトリに放り込みます。
* ディレクトリを移動して`vagrant up`します。
  - ↑もしRedisを使用しないアプリの場合はこの時に先に`EXCLUDE_REDIS=true`を指定する事でRedis環境の構築を省略する事ができます。
  - 例: `EXCLUDE_REDIS=true vagrant up`
* mariadb(mysql)を使用するかpostgresを使用するかを自動で判断し、`url: <%= ENV['MARIADB_URL'] %>`もしくは`url: <%= ENV['POSTGRES_URL'] %>`がRailsアプリの`config/database.yml`のdefault項目に自動で追加されます。

## `rails new`するのすら面倒な場合
* このリポジトリをcloneします。
* ディレクトリを移動して`vagrant up`します。
  - ↑この時、先に`APP_NAME`と`APP_DB`を環境変数として設定する事でアプリの名前と使用するデータベースを指定する事ができます。
  - 例: `APP_NAME=hoge APP_DB=postgresql vagrant up`
  - この場合**'Hoge'**という名前の**postgresql**を使用するRailsアプリが作成されます。
  - `APP_NAME`を指定しなかった場合はディレクトリ名が使用されますが、cloneした時のままの名前(Rails-DE)だと**App**という名前になります。
  - `APP_DB`には**mysql3 mariadb postgresql**の3つのうちいずれかを指定できます。デフォルトはmariadbです。
  - Redisを使用する予定が無い場合はこの時に先に`EXCLUDE_REDIS=true`を指定する事でRedis環境の構築を省略する事ができます。
  - 例: `EXCLUDE_REDIS=true vagrant up`
* 自動で新しいRailsアプリが作成されます。
* データベースの設定も自動で行われます。

# 使い方
`vagrant up`した後に`vagrant ssh -c run`と実行するとRailsアプリが起動し[192.168.33.33:3000](http://192.168.33.33:3000)でアクセスできるようになります。

# コマンド

#### `vagrant ssh -c bundle-install`
Gemfileに記述されているgemをインストールします。

#### `vagrant ssh -c bundle-update`
インストールされているgemをGemfileの記述に矛盾しない範囲で最新版にします。

#### `vagrant ssh -c setup`
データベースのセットアップを行います。
初回起動時に自動で行われるので通常は必要ないと思います。

#### `vagrant ssh -c migrate`
データベースのマイグレーションを行います。

#### `vagrant ssh -c server`
Railsサーバを起動します。

#### `vagrant ssh -c run`
`vagrant ssh -c bundle-install`と`vagrant ssh -c migrate`と`vagrant ssh -c server`を順次実行します。
通常アプリを起動する場合はこのコマンドを実行してください。

#### `vagrant ssh -c connect`
Railsが動作している環境に接続します。
`vagrant ssh -c server`を実行しRailsアプリが起動中である必要があります。

# 注意
* 3000番ポートを使用するので他のプログラムによって使用されていないか確認してください。
