# luatos-thingscloud-sdk

这是基于合宙模组 LuatOS 快速接入 ThingsCloud 物联网平台的 SDK ，可以帮你 10 分钟完成模组到云平台的双向通信。

## 特点

- 简单，简单，简单，填写几个参数就可以烧录运行。
- 可实现传感器数据上报和控制下发，利用各种外设发挥你的想象空间。
- 封装了 ThingsCloud 接入协议，只需调用函数和绑定事件，就可以实现设备和云平台双向通信。
- 支持自定义Topic，通过云平台设备类型的自定义数据流。
- 支持一型一密/自动注册设备，用于量产设备。
- 享受 ThingsCloud 云平台所有特性，一键生成物联网 SaaS 后台，以及用户 App，快速落地物联网项目和产品。

## 支持模组

- Air780E
- Air780EG
- Air600E

对于 Air724/820 系列模组，请移步到 [luat-thingscloud-libs](https://github.com/IoT-ThingsCloud/luat-thingscloud-libs)

## 使用方法

### 引用库文件

```lua
local ThingsCloud = require "ThingsCloud"
```

### 定义设备证书和连接参数

- 进入 ThingsCloud 控制台：https://www.thingscloud.xyz
- 创建项目，可选择免费版。
- 创建设备，进入设备详情页的【连接】页面，复制设备证书和MQTT接入点地址。请勿泄露你的设备证书。

![articles/2023/20230308225114_a177c9cd9a38216ca9872f51c8c31f9f.png](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230308225114_a177c9cd9a38216ca9872f51c8c31f9f.png)

```lua
-- 一机一密方式
-- ProjectKey
local projectKey = ""
-- AccessToken
local accessToken = ""
-- MQTT 接入点，只需主机名部分
local host = ""
```

### 连接 ThingsCloud

```lua
-- 设备接入云平台的初始化逻辑，在独立协程中完成
sys.taskInit(function()
    -- 连接云平台，支持判断网络可用性、MQTT自动重连
    -- 这里采用了设备一机一密方式，需要为每个设备固件单独写入证书。另外也支持一型一密，相同设备类型下的所有设备使用相同固件。
    ThingsCloud.connect({
        host = host,
        projectKey = projectKey,
        accessToken = accessToken,
    })
end)
```


## 示例项目

[Examples](https://github.com/IoT-ThingsCloud/luatos-thingscloud-sdk/tree/main/examples)

示例正在完善中，期待你的贡献……


### 连接云平台

#### 普通连接（一机一密）

#### 动态获取证书（一型一密）

### 和云平台双向通信

#### 属性上报

#### 接收下发属性

#### 获取云端属性

#### 事件上报

#### 接收下发命令

### 场景示例

#### 云平台控制 GPIO 输出 —— 网络继电器


#### SHT30 传感器上报


#### 云平台控制 PWM 输出 —— 电机调速


#### UART 串口透传模组


#### RS485 透传 —— 云平台解析 Modbus RTU


#### 开关实时检测 —— GPIO 输入实时上报


#### ADC 模拟量采集



## 