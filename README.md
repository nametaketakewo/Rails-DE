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
- mariadb(mysql)を使用するかpostgresを使用するかを自動で判断し、`url: <%= ENV['MARIADB_URL'] %>`もしくは`url: <%= ENV['POSTGRES_URL'] %>`がRailsアプリの`config/database.yml`のdefault項目に自動で追加されます。

## `rails new`するのすら面倒な場合
* このリポジトリをcloneします。
* ディレクトリを移動して`vagrant up`します。
* 自動で'app'という空のRailsアプリが作成されます。
* mariadb(mysql)の設定も自動で行われます。

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
