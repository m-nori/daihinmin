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
* ゲーム状況表示画面
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

* 1Placeにつき50Game行う。
* 1Gameにつき5Userで対戦を行う。
* 5Userの内訳は大富豪、富豪、平民、貧民、大貧民
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

### モデル構成

[モデルイメージ](https://github.com/m-nori/daihinmin/blob/master/doc/model.jpg "モデルイメージ")

### AIとの通信

AIとの通信は`WebSocket`と`HTTP-API`を使用する。

* WebSocket
  * 全プレイヤーに共通的に提供できる情報を送信する為に使用する。
    ゲームの開始通知やターンの開始通知などを全プレイヤーに送信する。
* HTTP-API
  * 手札の取得や、場にカードを出す為に使用する。
    プレイヤー毎に個別に処理する必要が有るため、使用するためにはユーザ認証を行ってから仕様する必要がある。

### WebScoket

ゲームの進行状況に合わせてサーバ側から送信される。
データはJSON形式となり、すべてのデータに以下の情報が含まれる。

* `place`
  * 場のID。自分の参加している場以外の情報も送信されてくるため、自分の場かどうかの判断をしてから処理する必要がある。
* `operation`
  * 行われたオペレーション。処理の判定に使用する。

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

