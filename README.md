# 大富豪大貧民用サーバ

## <a name="mokuji">目次</a>

* <a href="#gaiyou">概要</a>
* <a href="#kinou">機能一覧</a>
  * <a href="#kinou-1">全体管理</a>
  * <a href="#kinou-2">ゲームの管理</a>
  * <a href="#kinou-3">画面</a>
* <a href="#yougo">用語の定義</a>
* <a href="#rule">ルール</a>
  * <a href="#rule-1">基本ルール</a>
  * <a href="#rule-2">採用ルール</a>
  * <a href="#rule-3">不採用ルール</a>
* <a href="#architecture">アーキテクチャ</a>
  * <a href="#architecture-1">システム構成</a>
  * <a href="#architecture-2">モデル構成</a>
  * <a href="#architecture-3">通信方式</a>
* <a href="#websocket">WebScoketのデータ仕様</a>
  * <a href="#websocket-1">共通情報</a>
  * <a href="#websocket-2">各オペレーションのJSON</a>
      * <a href="#websocket-2-1">start_place</a>
      * <a href="#websocket-2-2">start_game</a>
      * <a href="#websocket-2-3">start_turn</a>
      * <a href="#websocket-2-4">end_player</a>
      * <a href="#websocket-2-5">end_turn</a>
      * <a href="#websocket-2-6">end_game</a>
      * <a href="#websocket-2-7">end_place</a>
* <a href="#api">プレイヤー用APIの仕様</a>
  * <a href="#api-1">ログイン</a>
      * <a href="#api-1-1">http://#{サーバ}/login</a>
  * <a href="#api-2">情報取得</a>
      * <a href="#api-2-1">http://#{サーバ}/get_hand.(json or xml)</a>
      * <a href="#api-2-2">http://#{サーバ}/get_place_info.(json or xml)</a>
  * <a href="#api-2">情報送信</a>
      * <a href="#api-2-1">http://#{サーバ}/post_cards</a>
* <a href="#flow">ゲームの進行</a>
  * <a href="#flow-1">フロー</a>
* <a href="#sample">AIの実装方法</a>
  * <a href="#sample-1">開発言語</a>
  * <a href="#sample-2">サンプル</a>
      * <a href="#sample-2-1">WebSocketの受信</a>
      * <a href="#sample-2-2">プレイヤーAPIの使用</a>
      * <a href="#sample-2-3">フロー制御</a>
* <a href="#todo">TODO</a>

## <a name="gaiyou">概要</a>

本プログラムは大富豪大貧民のAIを動作させるためのプラットフォームとなっている。  
ルールに基づいて作成されたAIプログラムがゲームを行うための機能を提供する。

## <a name="kinou">機能一覧</a>

### <a name="kinou-1">全体管理</a>

* 参加ユーザの追加、削除 
* ゲームを実行するための場の作成
* 場とユーザの結びつけ
* ゲームの進行管理

### <a name="kinou-2">ゲームの管理</a>

* 手札の配布
* 参加プレイヤーへの状況通知
* プレイヤー毎の限定情報提供用のAPI
* プレイヤーからの手の受け取り
* 場に出したカードが出すことが可能だったかどうかの判定
* ゲームごとの順位管理

### <a name="kinou-3">画面</a>

* 各種管理用画面
* ゲーム進行画面
* ゲーム結果表示画面
* 手動プレイ用画面

## <a name="yougo">用語の定義</a>

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

## <a name="rule">ルール</a>

ルールはシンプルにすることによりAI作成の難易度は下げている。

### <a name="rule-1">基本ルール</a>

* 1Placeにつき50ゲーム行う。
* ゲームは5ユーザで対戦を行う。
* 5ユーザの内訳は大富豪、富豪、平民、貧民、大貧民
* 大富豪・大貧民は2枚、富豪・貧民は1枚のカード交換を行う。
* 交換は、最弱カードと最強カードを自動で交換する。
* カードの枚数はジョーカーを2枚含めた54枚。
* 場に出せないカードを出したらその時点で負け。
* 手札を一定時間以内に出せなかった場合は負け。

### <a name="rule-2">採用ルール</a>
* 初回はハート3スタート
* 2回目以降は大貧民スタート（並び順は変更しない）
* 階段（3枚以上の場合のみ）
* 8切り
* 革命あり（ペアで4枚以上であればジョーカーを含んでいてもOK）
* 革命返し（革命条件を満たしている場でも、偶数回カードが出されている場合は革命返しとみなす。）
* ジョーカーor最強カード上がり禁止（行った場合はミスとみなす）

### <a name="rule-3">不採用ルール</a>
* 都落ち
* イレブンバック
* ジョーカーに対するスペード3返し
* 階段革命
* 縛り

## <a name="architecture">アーキテクチャ</a>

### <a name="architecture-1">システム構成</a>

* 開発言語
   * Ruby、JavaScript
* フレームワーク
   * Ruby on Rails
* DB
   * MySQL
* 対象ブラウザ
  * GoogleChrome、FireFox4

### <a name="architecture-2">モデル構成</a>

![モデルイメージ](/m-nori/daihinmin/blob/master/doc/model.jpg?raw=true "モデルイメージ")

### <a name="architecture-3">通信方式</a>

サーバとAI間の通信は`WebSocket`と`プレイヤー用API`を使用する。  
用途は以下のとおり。

* WebSocket
  * 全プレイヤーに共通的に提供できる情報を送信する為に使用する。
    ゲームの開始通知やターンの開始通知などを全プレイヤーに送信する。
* プレイヤー用API
  * 手札の取得や、場にカードを出す為に使用するHTTP通信のAPI。
    プレイヤー毎に個別に処理する必要が有るため、使用するためにはユーザ認証を行ってから仕様する必要がある。

![通信イメージ](/m-nori/daihinmin/blob/master/doc/image.jpg?raw=true "通信イメージ")

## <a name="websocket">WebScoketのデータ仕様</a>

ゲームの進行状況に合わせてサーバ側から送信される。  
データはJSON形式となり、すべてのデータに以下の情報が含まれる。

### <a name="websocket-1">共通情報</a>

* `place`
  * 場のID。自分の参加している場以外の情報も送信されてくるため、自分の場かどうかの判断をしてから処理する必要がある。
* `operation`
  * 行われたオペレーション。処理の判定に使用する。
* `card`
  1. joker:ジョーカーかどうかのフラグ。trueの場合ジョーカー。
  2. mark:カードのマーク。1〜4でどれが何かは決めていない。
  3. number:カードの数字。1〜13。

### <a name="websocket-2">各オペレーションのJSON</a>

#### <a name="websocket-2-1">start_place</a>
場の開始時に送信される。

* `place`
  * 場の情報。

例：

``` javascript
{"place":{
  "created_at":"2011-05-19T10:34:49Z",
  "game_count":3,
  "id":26,
  "title":"Place2",
  "updated_at":"2011-05-19T10:34:49Z"},
"operation":"start_place",
"place":26}
```

#### <a name="websocket-2-2">start_game</a>
ゲームの開始時に送信される。

* `game`
  * ゲームの情報。

例：

``` javascript
{"game":{
  "created_at":"2011-05-21T01:21:50Z",
  "id":269,"no":1,
  "place_id":26,
  "place_info":"Nomal",
  "status":0,
  "updated_at":"2011-05-21T01:21:50Z"},
"operation":"start_game",
"place":26}
```

#### <a name="websocket-2-3">start_turn</a>
ターンの開始時に送信される。

* `player`
  * ターンの回ってきたプレイヤーの名前。
* `place_cards`
  * 現在場に置かれているカード。配列になっており、カードがない場合は空の配列となる。
*  `place_info`
  * 場の情報。"Nomal"の場合通常、"Revolution"の場合革命中。

例：

``` javascript
{"player":"User3",
"place_cards":[
  {"card":
    {"created_at":"2011-04-20T13:32:09Z",
    "id":34,
    "joker":false,
    "mark":3,
    "number":8,
    "updated_at":"2011-04-20T13:32:09Z"}},
  {"card":
    {"created_at":"2011-04-20T13:32:09Z",
    "id":47,
    "joker":false,
    "mark":4,
    "number":8,
    "updated_at":"2011-04-20T13:32:09Z"}}],
"place_info":"Nomal",
"operation":"start_turn",
"place":26}
```

#### <a name="websocket-2-4">end_player</a>
プレイヤーが上がった場合、又はミスした場合に送信される。

* `player`
  * 対象のプレイヤーの名前。
* `rank`
  * 対象のプレイヤーのランク情報。rank.rank.rankが順位になる。

例：

``` javascript
{"player":"User5",
"rank":{
  "rank":{"created_at":null,
  "game_id":269,
  "player_id":15,
  "rank":1,
  "updated_at":null}},
"operation":"end_player",
"place":26}
```

#### <a name="websocket-2-5">end_turn</a>
ターンが終了したあと送信される。

* `player`
  * 対象のプレイヤーの名前。
* `turn_cards`
  * プレイヤーが出したカード。配列になっており、パスされた場合は空の配列となる。
* `reset_place`
  * 場がリセットされるかどうかのフラグ。リセットされる場合true。

例：

``` javascript
{"player":"User3",
"turn_cards":[
  {"card":
    {"created_at":"2011-04-20T13:32:09Z",
    "id":34,
    "joker":false,
    "mark":3,
    "number":8,
    "updated_at":"2011-04-20T13:32:09Z"}},
  {"card":
    {"created_at":"2011-04-20T13:32:09Z",
    "id":47,
    "joker":false,
    "mark":4,
    "number":8,
    "updated_at":"2011-04-20T13:32:09Z"}}],
"reset_place":true,
"operation":"end_turn",
"place":26}
```

#### <a name="websocket-2-6">end_game</a>
ゲームが終了したあと送信される。

* `game`
  * ゲームの情報。

例：

``` javascript
{"game":{
  "created_at":"2011-05-21T01:22:15Z",
  "id":270,
  "no":2,
  "place_id":26,
  "place_info":"Revolution",
  "status":1,
  "updated_at":"2011-05-21T01:22:39Z"},
"operation":"end_game",
"place":26}
```

#### <a name="websocket-2-7">end_place</a>
場が終了したあと送信される。

* `place`
  * 場の情報。

例：

``` javascript
{"place":{
  "created_at":"2011-05-19T10:34:49Z",
  "game_count":3,
  "id":26,
  "title":"Place2",
  "updated_at":"2011-05-19T10:34:49Z"},
"operation":"end_place",
"place":26}
```

## <a name="api">プレイヤー用APIの仕様</a>
プレイヤーが自分からアクセスすることで使用することが出来るHTTPのAPI。

### <a name="api-1">ログイン</a>
APIを使用するためにはこのURLにアクセスしてログインを行う必要がある。  
現時点ではログイン情報をCookieに保存するため、Cookie保存を行える言語で実装する必要がある。  
Cookie無しでログインできるようにするかは検討中。

#### <a name="api-1-1">http://#{サーバ}/login</a>

ユーザの認証を行う。  
クエリーパラメータは以下のとおり。

* `name`
  * ユーザ名
* `password`
  * パスワード
* `place_id`
  * 場のID

### <a name="api-2">情報取得</a>
情報取得はJSONとXMLにて行える。（JSON推奨）  
URLに".json"を付与した場合JSON、".xml"を付与した場合XMLとなる。  
HTTPメソッドは`get`。

#### <a name="api-2-1">http://#{サーバ}/get_hand.(json or xml)</a>
手札の取得を行う。

* `cards`
  * カードの配列。JSONの場合は配列のみ。
* `card`
  * カードの詳細情報。

例：JSON

``` javascript
[
  {"card":{"id":20,"joker":false,"mark":2,"number":7}},
  {"card":{"id":19,"joker":false,"mark":2,"number":6}},
  {"card":{"id":6,"joker":false,"mark":1,"number":6}},
  {"card":{"id":22,"joker":false,"mark":2,"number":9}}
]
```

例：XML

``` xml
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
```

#### <a name="api-2-2">http://#{サーバ}/get_place_info.(json or xml)</a>
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

``` javascript
{"game_count":10,
"player_count":5,
"player_infos":[
  {"name":"User1","has_card":4},
  {"name":"User2","has_card":1},
  {"name":"User3","has_card":6},
  {"name":"User4","has_card":7},
  {"name":"User5","has_card":4}]}
```

例：XML

``` xml
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
```

### <a name="api-3">情報送信</a>
データの送信フォーマットは未定。（現在はクエリーパラメータを使用）  
HTTPメソッドは`post`。

#### <a name="api-3-1">http://#{サーバ}/post_cards</a>
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

## <a name="flow">ゲームの進行</a>
ゲームの進行は`ゲーム進行画面`によって行われる。  
start_turn以外のタイミングでゲーム進行画面がサーバにnext_turn通知を行うことで次の処理へと遷移する。  
start_turnの次のみプレイヤーが場にカードを出すことで次の処理へと遷移する。（ただしタイムアウトした場合は強制的に次の処理へ進む）  
これはゲームの進行を画面から確認できるようにするためのものである。

### <a name="flow-1">フロー</a>

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
    <td>start_placeを送信する。</td>
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
    <td>start_gameを送信する。</td>
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
    <td>start_turnを送信する。</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>7</td>
    <td></td>
    <td></td>
    <td>場にカードを出す。</td>
  </tr>
  <tr>
    <td>8</td>
    <td>end_playerを送信する。</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>9</td>
    <td>end_turnを送信する。</td>
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
    <td>end_playerを送信する。</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>12</td>
    <td>end_gameを送信する。</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>13</td>
    <td></td>
    <td>next_turn通知を行う。</td>
    <td></td>
  </tr>
  <tr>
    <td>14</td>
    <td>end_placeを送信する。</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
</table>

* No.4〜13までの処理をGame回数分実行する。
* No.6〜9までの処理をGameが終了するまで実行する。
* No.8はNo.7の処理にてプレイヤーが終了した場合のみ発生する。
* No.11はプレイヤーが残り一人になった場合のみ発生する。

## <a name="sample">AIの実装方法</a>
AIは通信ルールに従って実装を行ってあれば言語・プラットフォームに依存しない。  
また、本ドキュメントにより公開されていないAPIを使用した場合は失格とする。

### <a name="sample-1">開発言語</a>
AIを実装する言語は以下の機能を実装できる必要がある。  
WebSocketの受信はJavaScript、その他の処理はJava等の使い分けでも問題ない。

1. WebSocket受信
  * サーバからの通知を受信するために必要。
  * Socket通信ができる言語であれば実装可能
2. HTTP通信
  * APIにアクセスするために必要。
3. Cookieの保存
  * APIへのログインにて必要。
  * JavaなどではApatchのHttpClient等を使用することで実装可能
4. スレッド処理
  * サーバからの通知は非同期で行われるため、通知に対する処理は別スレッドで処理することが望ましい。

### <a name="sample-2">サンプル</a>

#### <a name="sample-2-1">WebSocketの受信</a>
[Wikipedia](http://ja.wikipedia.org/wiki/WebSocket)等に仕様は記載されている。  
GoogleChromeやFireFox4であればブラウザ側で実装されているのでJavaScriptにて使用することができる。  
シンプルな仕様なので他の言語でゼロから作るのもそれほど難しく無いが、JavaやPythonにはClient側のライブラリもいくつか存在しているのでそれを使っても問題ない。  
HTTPSに対応させる必要は無い。  
サンプルのソースはRubyのEventMachineの上で動くように作った物。  
Socketの中身は適当なところが多いが、問題なく動作する。

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

#### <a name="sample-2-2">プレイヤーAPIの使用</a>
プレイヤーAPIを使用するためにはまずログインを行い、そのクッキーを使用してアクセする必要がある。  
そのためJavaではApatchのHttpClientライブラリ等を仕様する必要がある。  
サンプルはRubyのMechanizeというライブラリを使っており、そこでクッキー管理やHTMLスクレイピングを行っている。  
そのためloginやpost_cardsはformに対するsubmitだけで実行している。

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

#### <a name="sample-2-3">フロー制御</a>
AIの根幹部分となるフロー制御部分。  
WebSocketにて受信したのoperationに応じて処理を行う必要がある。  
start_turnにて自分のターンであれば手札から出せるカードを探し、プレイヤーAPIを使ってカードを出すのが基本的な処理となる。  
ゲーム開始時にプレイヤーAPIにて自分の手札を取得してからはできるだけWebSocketの情報を使って処理したほうが効率がいい。  
気をつけるべき箇所としてWebSocketは非同期で送信されてくるので、WebSocketの受信をブロックしていると情報が欠ける可能性がある。  
そのためWebSocketの受信部分と処理の中身は別スレッドとしたほうがいい。  
また、WebSocketからはJSON形式のデータが送られてくるはずであるが、JSONパーサでは空の文字列はパースエラーとなる。  
空の文字列は送られてくる可能性があるため、パースエラーとなっても処理を継続できるようにしておく必要がある。

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
    case json["operation"]
    when "end_place"
      exit(0)
    when "start_turn"
      Thread.new do
        # 出すカードを作る
        player_accsesor.post_cards(put_cards)
      end
    else
      puts json["operation"]
    end
  end
end
```

## <a name="todo">TODO</a>

* ゲーム結果表示画面作成
* 手動プレイ用画面作成
* サンプルに説明入れる…
* プレイヤー用APIで各プレイヤーのランクを取得できるようする
* プレイヤー用APIで初期手札（交換前）を取得できるようにする
