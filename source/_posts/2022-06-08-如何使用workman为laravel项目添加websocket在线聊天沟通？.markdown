---
layout: post
title:  "[php] 如何使用workman为laravel项目添加websocket在线聊天沟通？.markdown"
date:   2022-06-08 09:14:49 +0800
category: laravel workman websocket php
---




            第一步，

            composer require workerman/gateway-worker



            第二步，

            创建commond

            php artisan make:commond WorkermanCommand

            具体内容如下：

            <?php
            namespace App\Console\Commands;
            use App\Workerman\Events;
            use GatewayWorker\BusinessWorker;
            use GatewayWorker\Gateway;
            use GatewayWorker\Register;
            use Illuminate\Console\Command;
            use Workerman\Worker;
            class WorkermanCommand extends Command
            {
                protected $signature = 'workman {action} {--d}';
                protected $description = 'Start a Workerman server.';
                public function handle()
                {
                    global $argv;
                    $action = $this->argument('action');
                    $argv[0] = 'wk';
                    $argv[1] = $action;
                    $argv[2] = $this->option('d') ? '-d' : '';
                    $this->start();
                }
                private function start()
                {
                    $this->startGateWay();
                    $this->startBusinessWorker();
                    $this->startRegister();
                    Worker::runAll();
                }
                private function startBusinessWorker()
                {
                    $worker                  = new BusinessWorker();
                    //work名称
                    $worker->name            = 'BusinessWorker';
                    //businessWork进程数
                    $worker->count           = 2;
                    //服务注册地址 0.0.0.0
                    $worker->registerAddress = config('websocket.register_address').':1236';
                    //设置\App\Workerman\Events类来处理业务
                    $worker->eventHandler    = Events::class;
                }
                private function startGateWay()
                {
                    //gateway进程
                    $gateway = new Gateway("websocket://0.0.0.0:2346");
                    //gateway名称 status方便查看
                    $gateway->name                 = 'Gateway';
                    //gateway进程
                    $gateway->count                = 2;
                    //本机ip 0.0.0.0
                    $gateway->lanIp                = config('websocket.lan_ip');
                    //内部通讯起始端口，如果$gateway->count = 4 起始端口为2300
                    //则一般会使用 2300，2301 2个端口作为内部通讯端口
                    $gateway->startPort            = 2300;
                    //心跳间隔
                    $gateway->pingInterval         = 30;
                    //客户端连续$pingNotResponseLimit次$pingInterval时间内不发送任何数据则断开链接，并触发onClose。
                    //我们这里使用的是服务端主动发送心跳所以设置为0
                    $gateway->pingNotResponseLimit = 0;
                    //心跳数据
                    $gateway->pingData             = '{"type":"@heart@"}';
                    //服务注册地址
                    $gateway->registerAddress      = config('websocket.register_address').':1236';
                }
                private function startRegister()
                {
                    new Register('text://0.0.0.0:1236');
                }
            }

            第三步，

            创建Event.php

            具体代码如下：

            <?php

            namespace App\Workerman;

            use App\Models\User;
            use App\Services\ChartService;
            use GatewayWorker\Lib\Gateway;
            use Illuminate\Support\Facades\Cache;
            use Illuminate\Support\Facades\Log;

            class Events
            {
                // businessWorker进程启动事件
                public static function onWorkerStart($businessWorker)
                {
                    echo "BusinessWorker    Start\n";
                }
                /**
                * 当客户端连接时触发
                * 如果业务不需此回调可以删除onConnect
                *
                * @param int $client_id 连接id
                */
                public static function onConnect($clientId)
                {
                    Log::info('socket_message:客户端连接上gateway进程');
                    Log::info('客户端连接时的$clientId==' . $clientId);
                }
                // 当客户端连接上来时，设置连接的onWebSocketConnect，即在websocket握手时的回调
                public static function onWebSocketConnect($clientId)
                {
                    Log::info('socket_message:客户端连接上gateway完成websocket握手');
                    Log::info('握手的$clientId==' . $clientId);
                }

                public static function setClientId($token, $clientId)
                {
                    $sendUserClientId = Cache::get($token);
                    if (empty($sendUserClientId)) {
                        Cache::put($token, $clientId);
                    } else {
                        if ($sendUserClientId != $clientId) {
                            Cache::put($token, $clientId);
                        }
                    }
                }

                public static function updateUserMessageToken($userId, $token)
                {
                    //user表更新消息token
                }

                public static function getUserClientId($userId)
                {
                    //根据user信息，从缓存中取得clientId
                    return Cache::get($user->message_token);
                }

                /**
                * 当客户端发来消息时触发
                *
                * @param int   $client_id 连接id
                * @param mixed $message   具体消息
                */
                public static function onMessage($clientId, $message)
                {
                    Log::info('socket_message==' . $message);
                    Log::info('$clientId==' . $clientId);
                    $data = json_decode($message, true);
                    $sendUserId = $data['user_id'];
                    Log::info($data);
                    $token = $data['token'];
                    if (isset($data['send'])) {
                        $recipientUserId = $data['recipient_user_id'];
                        $toClientId = static::getUserClientId($recipientUserId);
                        Log::info('$toClientId==' . $toClientId);
                        $isOnline = Gateway::isOnline($toClientId);

                        //数据库消息存储操作

                        //toClientId exist and online and create success
                        if (!empty($toClientId) and $isOnline and $result['status']) {
                            //给发送方，发送一条消息
                            Gateway::sendToClient(
                                $clientId,
                                json_encode(['type' => 'send', 'status' => 'OK', 'messages' => $result['data']])
                            );
                            //给接收方发送一条消息
                            Gateway::sendToClient(
                                $toClientId,
                                json_encode(['type' => 'recipient', 'status' => 'OK', 'messages' => $result['data']])
                            );
                        } else {
                            Gateway::sendToClient(
                                $clientId,
                                json_encode(['status' => 'FAIL', 'messages' => 'toClientId不存在或者不在线'])
                            );
                        }
                    } else {
                        static::updateUserMessageToken($sendUserId, $token);
                        // Gateway::bindUid($clientId, $sendUserId);
                        static::setClientId($token, $clientId);
                    }
                }

                /**
                * 当用户断开连接时触发
                *
                * @param int $client_id 连接id
                */
                public static function onClose($clientId)
                {
                    Log::info('socket_message:断开连接');
                }
            }
            页面调用：

            const webSocket = new WebSocket('ws://localhost');

            // set clientId
            webSocket.onopen = () => {
                console.log('start set client_id');
                console.log('token===' + token);
                webSocket.send(stringify({ 'token': token, 'user_id': sendUserId }));
            }
            webSocket.onmessage=(message)=> {
                //get info show on client
                console.log(message);
                if (message && message.data) {
                            //按照发送的数据结构进行处理即可

                      }

            }