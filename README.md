# 大富豪大貧民用サーバAP

## 概要

本プログラムは大富豪大貧民のAIを動作させるためのプラットフォームとなっている。
ルールに基づいて作成されたAIプログラムがゲームを行うための機能を提供する。

## 機能一覧

### 全体管理

* 参加ユーザの追加、削除 
* ゲームを実行するための場の作成
* 場とユーザの結びつけ
* ゲームの進行管理

### ゲームの管理

* 手札の配布
* 参加プレイヤーへの状況通知
* プレイヤー毎の限定情報提供用のAPI
* プレイヤーからの手の受け取り
* 場に出したカードが出すことが可能だったかどうかの判定
* ゲームごとの順位管理

### 画面

* 各種管理用画面
* ゲーム進行画面
* ゲーム結果表示画面
* 手動プレイ用画面

## 用語の定義

<table>
  <tr>
    <th>名前</th>
    <th>意味</th>
  </tr>
  <tr>
    <td>User</td>
    <td>ゲームに参加するユーザ。</td>
  </tr>
  <tr>
    <td>Place</td>
    <td>参加するユーザとゲームを保持する場のこと。場の中でゲームが行われる。</td>
  </tr>
  <tr>
    <td>Player</td>
    <td>場に参加するユーザのこと。</td>
  </tr>
  <tr>
    <td>Game</td>
    <td>場の中で行われるゲーム。大富豪大貧民の基本単位。</td>
  </tr>
  <tr>
    <td>Turn</td>
    <td>ゲームの中でのプレイヤーの一行動。</td>
  </tr>
</table>

## ルール

ルールはシンプルにすることによりAI作成の難易度は下げている。

### 基本ルール

* 1Placeにつき50ゲーム行う。
* ゲームは5ユーザで対戦を行う。
* 5ユーザの内訳は大富豪、富豪、平民、貧民、大貧民
* 大富豪・大貧民は2枚、富豪・貧民は1枚のカード交換を行う。
* 交換は、最弱カードと最強カードを自動で交換する。
* カードの枚数はジョーカーを2枚含めた54枚。
* 場に出せないカードを出したらその時点で負け。
* 手札を一定時間以内に出せなかった場合は負け。

### 採用ルール
* 初回はハート3スタート
* 2回目以降は大貧民スタート（並び順は変更しない）
* 階段（3枚以上の場合のみ）
* 8切り
* 革命あり（ペアで4枚以上であればジョーカーを含んでいてもOK）
* ジョーカーor最強カード上がり禁止（行った場合はミスとみなす）

### 不採用ルール
* 都落ち
* イレブンバック
* ジョーカーに対するスペード3返し
* 階段革命
* 縛り

## アーキテクチャ

### 構成

* 開発言語
   * Ruby、JavaScript
* フレームワーク
   * Ruby on Rails
* DB
   * MySQL
* 対象ブラウザ
  * GoogleChrome、FireFox4

### モデル構成

[モデルイメージ](https://github.com/m-nori/daihinmin/blob/master/doc/model.jpg "モデルイメージ")

### 通信方式

AIとの通信は`WebSocket`と`プレイヤー用API`を使用する。

[通信イメージ](https://github.com/m-nori/daihinmin/blob/master/doc/image.jpg "通信イメージ")

* WebSocket
  * 全プレイヤーに共通的に提供できる情報を送信する為に使用する。
    ゲームの開始通知やターンの開始通知などを全プレイヤーに送信する。
* プレイヤー用API
  * 手札の取得や、場にカードを出す為に使用するHTTP通信のAPI。
    プレイヤー毎に個別に処理する必要が有るため、使用するためにはユーザ認証を行ってから仕様する必要がある。

## WebScoketのデータ仕様

ゲームの進行状況に合わせてサーバ側から送信される。
データはJSON形式となり、すべてのデータに以下の情報が含まれる。

### 共通情報

* `place`
  * 場のID。自分の参加している場以外の情報も送信されてくるため、自分の場かどうかの判断をしてから処理する必要がある。
* `operation`
  * 行われたオペレーション。処理の判定に使用する。
* `card`
  1. joker:ジョーカーかどうかのフラグ。trueの場合ジョーカー。
  2. mark:カードのマーク。1〜4でどれが何かは決めていない。
  3. number:カードの数字。1〜13。

### 各オペレーションのJSON

#### start_place
場の開始時に送信される。

* `place`
  * 場の情報。

例：

    {"place":{
      "created_at":"2011-05-19T10:34:49Z",
      "game_count":3,
      "id":26,
      "title":"Place2",
      "updated_at":"2011-05-19T10:34:49Z"
    },
    "operation":"start_place",
    "place":26}

#### start_game
ゲームの開始時に送信される。

* `game`
  * ゲームの情報。

例：

    {"game":{
      "created_at":"2011-05-21T01:21:50Z",
      "id":269,"no":1,
      "place_id":26,
      "place_info":"Nomal",
      "status":0,
      "updated_at":"2011-05-21T01:21:50Z"
    },
    "operation":"start_game",
    "place":26}


#### start_turn
ターンの開始時に送信される。

* `player`
  * ターンの回ってきたプレイヤーの名前。
* `place_cards`
  * 現在場に置かれているカード。配列になっており、カードがない場合は空の配列となる。
*  `place_info`
  * 場の情報。"Nomal"の場合通常、"Revolution"の場合革命中。

例：

    {"player":"User3",
    "place_cards":[
      {"card":
        {"created_at":"2011-04-20T13:32:09Z",
        "id":34,
        "joker":false,
        "mark":3,
        "number":8,
        "updated_at":"2011-04-20T13:32:09Z"}
      },
      {"card":
        {"created_at":"2011-04-20T13:32:09Z",
        "id":47,
        "joker":false,
        "mark":4,
        "number":8,
        "updated_at":"2011-04-20T13:32:09Z"}
      }
    ],
    "place_info":"Nomal",
    "operation":"start_turn",
    "place":26}

#### end_player
プレイヤーが上がった場合、又はミスした場合に送信される。

* `player`
  * 対象のプレイヤーの名前。
* `rank`
  * 対象のプレイヤーのランク情報。rank.rank.rankが順位になる。

例：

    {"player":"User5",
    "rank":{
      "rank":{"created_at":null,
      "game_id":269,
      "player_id":15,
      "rank":1,
      "updated_at":null}
    },
    "operation":"end_player",
    "place":26}

#### end_turn
ターンが終了したあと送信される。

* `player`
  * 対象のプレイヤーの名前。
* `turn_cards`
  * プレイヤーが出したカード。配列になっており、パスされた場合は空の配列となる。
* `reset_place`
  * 場がリセットされるかどうかのフラグ。リセットされる場合true。

例：

    {"player":"User3",
    "turn_cards":[
      {"card":
        {"created_at":"2011-04-20T13:32:09Z",
        "id":34,
        "joker":false,
        "mark":3,
        "number":8,
        "updated_at":"2011-04-20T13:32:09Z"}
      },
      {"card":
        {"created_at":"2011-04-20T13:32:09Z",
        "id":47,
        "joker":false,
        "mark":4,
        "number":8,
        "updated_at":"2011-04-20T13:32:09Z"}
      }
    ],
    "reset_place":true,
    "operation":"end_turn",
    "place":26}

#### end_game
ゲームが終了したあと送信される。

* `game`
  * ゲームの情報。

例：

    {"game":{
      "created_at":"2011-05-21T01:22:15Z",
      "id":270,
      "no":2,
      "place_id":26,
      "place_info":"Revolution",
      "status":1,
      "updated_at":"2011-05-21T01:22:39Z"
    },
    "operation":"end_game",
    "place":26}

#### end_place
場が終了したあと送信される。

* `place`
  * 場の情報。

例：

    {"place":{
      "created_at":"2011-05-19T10:34:49Z",
      "game_count":3,
      "id":26,
      "title":"Place2",
      "updated_at":"2011-05-19T10:34:49Z"
    },
    "operation":"end_place",
    "place":26}

## プレイヤー用APIの仕様
プレイヤーが自分からアクセスすることで使用することが出来るHTTPのAPI。

### ログイン
APIを使用するためにはこのURLにアクセスしてログインを行う必要がある。

現時点ではログイン情報をCookieに保存するため、Cookie保存を行える言語で実装する必要がある。

#### http://#{サーバ}/login
ユーザの認証を行う。
クエリーパラメータは以下のとおり。

* `name`
  * ユーザ名
* `password`
  * パスワード
* `place_id`
  * 場のID

### 受信
データの受信はJSONとXMLにて行える。（JSON推奨）

URLに".json"を付与した場合JSON、".xml"を付与した場合XMLとなる。

HTTPメソッドは`get`。

#### http://#{サーバ}/get_hand.(json or xml)
手札の取得を行う。

* `cards`
  * カードの配列。JSONの場合は配列のみ。
* `card`
  * カードの詳細情報。

例：JSON

    [
      {"card":{"id":20,"joker":false,"mark":2,"number":7}},
      {"card":{"id":19,"joker":false,"mark":2,"number":6}},
      {"card":{"id":6,"joker":false,"mark":1,"number":6}},
      {"card":{"id":22,"joker":false,"mark":2,"number":9}}
    ]

例：XML

    <cards type="array">
      <card>
        <id type="integer">20</id>
        <joker type="boolean">false</joker>
        <mark type="integer">2</mark>
        <number type="integer">7</number>
      </card>
      <card>
        <id type="integer">19</id>
        <joker type="boolean">false</joker>
        <mark type="integer">2</mark>
        <number type="integer">6</number>
      </card>
      <card>
        <id type="integer">6</id>
        <joker type="boolean">false</joker>
        <mark type="integer">1</mark>
        <number type="integer">6</number>
        </card>
      <card>
        <id type="integer">22</id>
        <joker type="boolean">false</joker>
        <mark type="integer">2</mark>
        <number type="integer">9</number>
      </card>
    </cards>

#### http://#{サーバ}/get_place_info.(json or xml)
場の情報を取得を行う。

* `game_count`
  * ゲームの実行回数。
* `player_count`
  * 参加しているプレイヤーの人数。
* `player_infos`
  * プレイヤーの情報の配列。JSONの場合は配列のみ。
* `player_info`
  * プレイヤーの情報。ユーザ名と持っているカードの残数。

例：JSON

    {"game_count":10,
    "player_count":5,
    "player_infos":[
      {"name":"User1","has_card":4},
      {"name":"User2","has_card":1},
      {"name":"User3","has_card":6},
      {"name":"User4","has_card":7},
      {"name":"User5","has_card":4}
    ]}

例：XML

    <hash>
      <game-count type="integer">10</game-count>
      <player-count type="integer">5</player-count>
      <player-infos type="array">
        <player-info>
          <name>User1</name>
          <has-card type="integer">4</has-card>
        </player-info>
        <player-info>
          <name>User2</name>
          <has-card type="integer">1</has-card>
        </player-info>
        <player-info>
          <name>User3</name>
          <has-card type="integer">6</has-card>
        </player-info>
        <player-info>
          <name>User4</name>
          <has-card type="integer">7</has-card>
        </player-info>
        <player-info>
          <name>User5</name>
          <has-card type="integer">4</has-card>
        </player-info>
      </player-infos>
    </hash>

### 送信
データの送信フォーマットは未定。（現在はクエリーパラメータを使用）

HTTPメソッドは`post`。

#### http://#{サーバ}/post_cards
手札を場に出す。
クエリーパラメータは以下のとおり。

* card_0 〜 5
  * 出すカードを一つずつ指定して格納する。
    パスの場合はクエリーパラメータを指定しないで出す。
  * 格納する値の使用は以下のとおり。
    * `ジョーカーの場合：`joker
    * `ジョーカー以外の場合：`#{マーク}-#{数字}

例：ハート3、ダイヤ3、ジョーカー

    card_0 => "2-3"
    card_0 => "3-3"
    card_0 => "joker"

## ゲームの進行
ゲームの進行は`ゲーム進行画面`によって行われる。

start_turn以外のタイミングでゲーム進行画面がサーバにnext_turn通知を行うことで次の処理へと遷移する。

start_turnの次のみプレイヤーが場にカードを出すことで次の処理へと遷移する。（ただしタイムアウトした場合は強制的に次の処理へ進む）

これはゲームの進行を画面から確認できるようにするためのものである。

### フロー

<table>
  <tr>
    <th>No.</th>
    <th>サーバ</th>
    <th>ゲーム進行画面</th>
    <th>プレイヤー</th>
  </tr>
  <tr>
    <td>1</td>
    <td></td>
    <td>start通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>2</td>
    <td>WebSocket:start_place</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>3</td>
    <td></td>
    <td>next_turn通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>4</td>
    <td>WebSocket:start_game</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>5</td>
    <td></td>
    <td>next_turn通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>6</td>
    <td>WebSocket:start_turn</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>7</td>
    <td></td>
    <td></td>
    <td>対象プレイヤーが場にカードを出す。</td>
  </tr>
  <tr>
    <td>8</td>
    <td>WebSocket:end_player</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>9</td>
    <td>WebSocket:end_turn</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>10</td>
    <td></td>
    <td>next_turn通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>11</td>
    <td>WebSocket:end_game</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>12</td>
    <td></td>
    <td>next_turn通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>13</td>
    <td>WebSocket:end_place</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
</table>

* No.4〜12までの処理をGame回数分実行する。
* No.6〜9までの処理をGameが終了するまで実行する。
* No.8はNo.7の処理にてプレイヤーが終了した場合のみ発生する。

## AIの実装方法
AIを実装するためには以下機能保持している言語で実装する必要がある。

1. WebSocketの受信
  * サーバからの通知を受信するために必要。
  * Socket通信ができる言語であれば実装可能
2. HTTP通信
  * APIにアクセスするために必要。
3. Cookieの保存
  * APIへのログインにて必要。
  * JavaなどではApatchのHttpClient等を使用することで実装可能
4. スレッド処理
  * サーバからの通知は非同期で行われるため、通知に対する処理は別スレッドで処理することが望ましい。

### サンプル

WebSocketの受信：

``` ruby
require "EventMachine"

class WebsocketClient < EventMachine::Connection
  include EventMachine::Deferrable
  
  def initialize
    @callbacks = []
  end
  
  def self.connect(host, port, callback = nil, &block)
    EventMachine::connect(host, port, self) do |conn|
      conn.add_callback(callback) unless callback.nil?
      conn.add_callback(nil, &block) if block_given?
    end
  end  
  
  def add_callback callback = nil, &block
    @callbacks.push(callback || block)
  end

  def post_init
    request = "GET / HTTP/1.1\r\n"
                request << "Upgrade: WebSocket\r\n"
                request << "Connection: Upgrade\r\n"
                request << "Host: 127.0.0.1\r\n"
                request << "Origin: TODO\r\n"
    request << "\r\n"
    send_data request
    @data = ""
    @handshake = false
    @index = 0
  end

  def receive_data data
    @data << data
    if !@handshake
      if @data =~ /[\n][\r]*[\n]/m
        if @data =~ /HTTP\/1.1 101 Web Socket Protocol Handshake/
          @handshake = true
          @data = ""
        else
          close_connection  
        end
      end  
    elsif @data =~ /^\x00(.*)\xff$/m
      @data.scan(/^\x00(.*)\xff$/m) do |message|
        @callbacks.each do |callback|
          callback.call message
        end  
      end  
      @data = ""
      @index += 1;
    end
  end

  def unbind
    puts "A connection has terminated"
  end    
end
```

プレイヤーAPIの使用：

``` ruby
require 'Mechanize'

class PlayerAccsesor
  LOGIN_URL = "/login"
  GET_HAND_URL = "/operations/get_hand.json"
  OPERATION_URL = "/operations"

  def initialize(url, user_name, password, place_id)
    @url = url
    @agent = Mechanize.new
    @agent.log = Logger.new($stderr)
    @agent.log.level = Logger::INFO

    # login execute
    page = @agent.get(@url + LOGIN_URL)
    form = page.forms.first
    form["name"] = user_name
    form["password"] = password
    form["place_id"] = place_id
    form.submit
  end

  def get_hand
    json = @agent.get_file(GET_HAND_URL)
    JSON.parse(json)
  end

  def post_cards(cards)
    page = @agent.get(OPERATION_URL)
    form = page.forms.first
    cards.each_with_index do |card,i|
      form["card_#{i}"] = card_to_string(card)
    end
    form.submit
  end

  private
  def card_to_string(card)
    if card[:joker]
      "joker"
    else
      "#{card[:mark]}-#{card[:number]}"
    end
  end
end
```

フロー制御：

``` ruby
EM.run do
  player_accsesor = PlayerAccsesor.new("http://localhost:3000", user_name, password, place_id)
  WebsocketClient.connect("localhost", 8081) do |data|
    begin
      json = JSON.parse(data[0])
    rescue
      puts "not json"
      next
    end
    next if json["place"] != place_id.to_i
    when "end_place"
      exit(0)
    when "start_turn"
      Thread.new do
        # 手札を作る
        player_accsesor.post_cards(put_cards)
      end
    else
      puts json["operation"]
    end
  end
end
```

## TODO

* ゲーム結果表示画面作成
* 手動プレイ用画面作成
* サンプルに説明入れる…
* プレイヤー用APIで各プレイヤーのランクを取得できるようにして欲しいです by kannos
