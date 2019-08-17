---
layout: post
title: Telegram Bot - Ứng dụng trong việc theo dõi tính ổn định của sản phẩm
description: Triển khai sendMessage sử dụng Telegram, ứng dụng nhắn tin và cảnh báo, theo dõi sản phẩm
image: /img/posts/2019-08-17-telegram.jpg
---

Hey, cuối tuần rảnh rỗi dành thời gian viết bài chia sẻ cách build 1 ứng dụng chatbot Telegram và dùng nó trong việc quản lý và theo dõi sản phẩm.

## Case Study

Case đặt ra ở đây là hiện tại ông A đang quản lý 1 ứng dụng với lượng request lớn. Ứng dụng của ông A được thiết kế theo mô hình micro-service với việc gọi giữa các service với nhau có tỉ lệ thất thoát dữ liệu cũng như bị lạm dụng.

Đồng thời, product của ông A là 1 sản phẩm có bán sản phẩm hàng ngày. Đội sale yêu cầu ông A làm 1 cái gì đó để hàng ngày đúng 6 sáng họ mở mắt dậy ăn sáng bằng doanh số ngày hôm trước.

Trước đây ông A làm report bằng Email và kênh SMS private. Tuy nhiên, SMS thì ngày 1 đắt (500d/tin, buổi sáng gửi hết bát phở), Email thì phức tạp nên đội sale đôi khi cũng lười check.

Ông A khổ tâm lắm. Ông A quyết tâm nghĩ ra cách gì đó để report bắn liên tục mà bản thân nó phải nhanh, đơn giản và độ trễ thấp.

Tình cờ, ông A tìm ra thằng [telegram.org](https://telegram.org/), 1 app OTT Message thịnh hành,  có app cho điện thoại và cả máy tính, có document rõ ràng và đơn giản. Đặc biệt đáp ứng được vấn đề ***chia sẻ one-one*** mà không cần phải add group.

Và dưới đây là cách ông A thực hiện.

## Chuẩn bị nguyên liệu

1. Ông A thì thích PHP, nên nguyên liệu chính ông A sử dụng là PHP, kèm theo Composer cho nó ngầu.
2. Ông A sẽ build nó thành 1 API interface, build thành packages để có thể install nhanh vào project hoặc implement thành 1 restful API 1 cách đơn giản nhất
3. Ông A cũng cẩn thận lưu log mọi request lại
4. 1 cái IDE hoặc Text Editor để code
5. Tài khoản và App Telegram, đương nhiên rồi
6. Cốc nước lọc để code cho đỡ đói. 

## Triển khai

#### Nguồn tài liệu chính

Tài liệu về Telegram BOT được trình bày ở đây, đầy đủ, chi tiết, bằng tiếng Anh: https://core.telegram.org/bots

### Đăng ký BOT với Telegram

Đầu tiên, để được Telegram cấp bot, bạn phải gọi Telegram bằng bố. Kiểu bố ơi, con muốn được giao tiếp với thế giới...

![https://i.imgur.com/KsA8x7n.png](https://i.imgur.com/KsA8x7n.png)

Đó, thấy đó, nó bắt ông A gọi là bố. Phận coder bèo bọt, để hoàn thành công việc kiếm gói mì tôm thay cốc nước lọc. Ông A đành nhắm mắt gọi nó là bố vậy.

Mở app Telegram lên, ông A search đến cái thằng **@BotFather** và trò chuyện với ông bố này.

![https://i.postimg.cc/x1Z9ShWY/Screen-Shot-2019-08-17-at-23-41-21.png](https://i.postimg.cc/x1Z9ShWY/Screen-Shot-2019-08-17-at-23-41-21.png)



Tìm được bố rồi, gõ **/help** để được bố nhìn thấy và trợ giúp

![https://i.postimg.cc/VN9ZFb9T/Screen-Shot-2019-08-17-at-23-43-17.png](https://i.postimg.cc/VN9ZFb9T/Screen-Shot-2019-08-17-at-23-43-17.png)



Đó, sau khi gõ **/help**, hắn reply ngay, đại ý là tao giúp được gì cho mày. Nếu mày muốn tạo bot mới thì mày phải chơi theo luật của tao. Và dưới đây là vài cái tao có thể giúp mày.

Mạnh dạn gõ **/newbot** để tạo bot mới

![https://i.ibb.co/P64LVsr/Screen-Shot-2019-08-17-at-23-45-16.png](https://i.ibb.co/P64LVsr/Screen-Shot-2019-08-17-at-23-45-16.png)

Sau đó nhập tên bot cần tạo vào ô chat, ở đây ông A lập cái bot tên là **Test Bot Chơi** và username cho bot là **ong_a_test_bot**

![https://i.postimg.cc/QMx9t2Mz/Screen-Shot-2019-08-17-at-23-49-11.png](https://i.postimg.cc/QMx9t2Mz/Screen-Shot-2019-08-17-at-23-49-11.png)

Đó, tạo bot xong, nó trả cho ông A cái token access, là đoạn 

> 892069632:AAFbjTC98f0k-zQUq00pf38v5VbR4f6L4hw

Lưu đoạn này lại. OK, vậy là h có 1 con bot tồn tại tên là **ong_a_test_bot** trên cõi đời này

search thử con bot trên telegram và start chat với nó phát

![https://i.postimg.cc/mZq5SRfQ/Screen-Shot-2019-08-17-at-23-51-56.png](https://i.postimg.cc/mZq5SRfQ/Screen-Shot-2019-08-17-at-23-51-56.png)

Đến đây là xong bước đăng ký BOT với Telegram rồi.

### Code module Send Message với con BOT mình vừa đăng ký

Do triển khai dạng composer nên việc đầu tiên là init composer, sau đó đăng ký sử dụng 2 packages

1. monolog/monolog: dùng để ghi log sự kiện
2. php-curl-class/php-curl-class: đây là 1 wrapper curl rất tiện dụng
3. Endpoint để gọi: https://api.telegram.org/bot<token>/method

file composer ông A xây dựng có dạng sau

```json
{
    "name": "tungvandev/scripts-telegram-bot-send-message",
    "type": "library",
    "description": "Script Telegram Bot Send Message",
    "keywords": [
        "telegram",
        "bot",
        "send message",
        "example"
    ],
    "homepage": "https://github.com/tungvandev/scripts-telegram-bot-send-message",
    "license": "GPL-3.0",
    "authors": [
        {
            "name": "Nguyen An Hung",
            "email": "dev@nguyenanhung.com",
            "homepage": "https://nguyenanhung.com",
            "role": "Developer"
        }
    ],
    "require": {
        "ext-curl": "*",
        "ext-json": "*",
        "ext-openssl": "*",
        "monolog/monolog": "^1.24",
        "php-curl-class/php-curl-class": "^8.6"
    },
    "require-dev": {
        "kint-php/kint": "^3.0"
    },
    "autoload": {
        "psr-4": {
            "tungvandev\\Example\\TelegramBOT\\": "src/"
        }
    }
}

```

và cấu trúc thư mục của ông A

```shell
.
├── README.md
├── test.php
├── config.php
├── composer.json
├── composer.lock
├── src
│   └── Telegram.php
└── vendor
└── logs
```

trong đó

class src/Telegram.php là Class chịu trách nhiệm xử lý chính các tác vụ

test.php là file test class send Message. API Restful các ông tự xây nhé :))

config.php là file lưu dữ liệu cấu hình

##### Init class Telegram

Đầu tiên, khởi tạo class **Telegram.php** và đăng ký các biến request, config và logger, file sẽ tương tự như sau

```php
<?php

namespace tungvandev\Example\TelegramBOT;

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Curl\Curl;

/**
 * Class Telegram
 *
 * @package tungvandev\Example\TelegramBOT
 */
class Telegram
{

    private $request; // Alias cURL
    private $logger; // Logger
    private $config; // Mảng cấu hình thông tin BOT
    private $result;

    /**
     * Telegram constructor.
     *
     * @throws \ErrorException
     * @throws \Exception
     */
    public function __construct()
    {
        $this->request = new Curl();
        // create a log channel
        $this->logger = new Logger('telegram');
        $this->logger->pushHandler(new StreamHandler(__DIR__ . '/../logs', Logger::INFO));
    }
		/**
     * @return mixed
     */
    public function getResult()
    {
        return $this->result;
    }
    /**
     * @param array $config
     *
     * @return $this
     */
    public function setConfig($config = [])
    {
        $this->config = $config;

        return $this;
    }

    /**
     * @return mixed
     */
    public function getConfig()
    {
        return $this->config;
    }
}


```

và setup cấu hình tại file **config.php**

```php
<?php
return [
    'bot_name'  => 'ong_a_test_bot',
    'bot_token' => '892069632:AAFbjTC98f0k-zQUq00pf38v5VbR4f6L4hw'
];

```



##### Xây dựng hàm gửi tin nhắn

Hàm gửi tin nhắn của Telegram chúng ta có thể tìm thấy ngay tại đây: https://core.telegram.org/bots/api#sendmessage

![https://i.postimg.cc/V6BbkXQY/Screen-Shot-2019-08-18-at-00-13-12.png](https://i.postimg.cc/V6BbkXQY/Screen-Shot-2019-08-18-at-00-13-12.png)



OK, phân tích api document, ta thấy để gửi được tin nhắn đi thì chỉ cần đơn giản 2 trường là chat_id và text, đối với trường hợp group thì chat_id chính là id của cuộc trò chuyện đó

##### Lấy thông tin chat_id

Đơn giản, gọi đến endpoint getUpdates để lấy thông tin các user đã tương tác với BOT

![https://i.postimg.cc/YCLcK3Ym/Screen-Shot-2019-08-18-at-00-20-37.png](https://i.postimg.cc/YCLcK3Ym/Screen-Shot-2019-08-18-at-00-20-37.png)

anh em thấy đoạn bôi đen rồi chứ, nó đó, chat_id đó

Từ đó, ta xây dựng được thêm mấy hàm sau trong class Telegram, tôi đã comment kĩ, các ông chịu khó đọc ha

```php
		/**
     * Hàm gửi Message qua Telegram
     *
     * @return bool
     */
    public function sendMessage()
    {
        // Bắt lỗi
        // Ko tồn tại chat_id || message || không xác định được request
        if (empty($this->chat_id) || empty($this->message) || empty($this->config) || !isset($this->config['bot_token'])) {
            return FALSE;
        }
        // Xác đinh Endpoint gửi tin đi
        $endpoint = 'https://api.telegram.org/bot' . $this->config['bot_token'] . '/sendMessage';

        // Xác định Request gửi tin đi
        $params = [
            'chat_id' => $this->chat_id,
            'text'    => $this->message
        ];

        // Request tới Telegram
        $handle = $this->request->get($endpoint, $params);
        if ($handle->error) {
            return FALSE;
        }

        // Nếu không có lỗi gì, request response sẽ trả 1 object
        // Example: stdClass (2) (
        //    public 'ok' -> boolean true
        //    public 'result' -> stdClass (5) (
        //        public 'message_id' -> integer 10
        //        public 'from' -> stdClass (4) (
        //            public 'id' -> integer 892069632
        //            public 'is_bot' -> boolean true
        //            public 'first_name' -> UTF-8 string (13) "Test Bot Chơi"
        //            public 'username' -> string (14) "ong_a_test_bot"
        //        )
        //        public 'chat' -> stdClass (5) (
        //            public 'id' -> integer 474860058
        //            public 'first_name' -> string (4) "Hung"
        //            public 'last_name' -> string (6) "Nguyen"
        //            public 'username' -> string (12) "nguyenanhung"
        //            public 'type' -> string (7) "private"
        //        )
        //        public 'date' -> integer 1566063717
        //        public 'text' -> UTF-8 string (29) "Test con bot chơi cái nhờ :))"
        //    )
        //)
        
        if (empty($handle)) {
            // Không xác định được response, lỗi chứ còn gì nữa
            return FALSE;
        }
        if (isset($handle->ok) && $handle->ok == TRUE) {
            // Send Message thành công, body trường ok == true
            return TRUE;
        }

        return FALSE;


    }
```

Vậy là cơ bản xong class Send Message. Mỗi khi gọi hàm Send, response == true là thành công, false các ông check log

#### OK, vậy là cơ bản xong, h xây dựng file test thử cái nhờ

File test xây dựng đơn giản như vậy thôi



```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use tungvandev\Example\TelegramBOT\Telegram;

// Nạp config
$config = require_once __DIR__ . '/config.php';

// Khởi tạo class telegram
$telegram = new Telegram();

$telegram->setConfig($config)
         ->setChatId(474860058)
         ->setMessage('Test con bot chơi cái nhờ :))');

// Send Message

$result = $telegram->sendMessage();

d($result);

```



và tận hưởng thành quả :))

![https://i.postimg.cc/FKkzC89d/Screen-Shot-2019-08-18-at-00-44-45.png](https://i.postimg.cc/FKkzC89d/Screen-Shot-2019-08-18-at-00-44-45.png)

### Kết

Rồi, bây h các ông đã sở hữu trong tay con bot mạnh mẽ rồi. Việc còn lại các ông implement vào project của mình dạng package cũng được, mà xây restful API cũng được.

Tôi đã build nhanh packages [ở đây](https://packagist.org/packages/tungvandev/scripts-telegram-bot-send-message), các ông có thể install nhanh chóng với cú pháp require

> composer require tungvandev/scripts-telegram-bot-send-message

Còn đây là full source không che

> https://github.com/tungvandev/scripts-telegram-bot-send-message

Còn logic nghiệp vụ bắt lỗi ở đâu, đó tùy nghiệp vụ với quan điểm từng người, tôi không chỉ được.

Nếu các ông cần trợ giúp, liên hệ sau sẽ có ích với các ông

| Name        | Email                | Skype            | Facebook      |
| ----------- | -------------------- | ---------------- | ------------- |
| Hung Nguyen | dev@nguyenanhung.com | nguyenanhung5891 | @nguyenanhung |

