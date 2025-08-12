# luatos-thingscloud-sdk

这里是基于合宙模组 [LuatOS](https://wiki.luatos.com/) 快速接入 [ThingsCloud](https://www.thingscloud.xyz) 物联网平台的 SDK ，帮你 10 分钟完成模组到云平台的双向通信，一键生成物联网 SaaS 后台，以及用户 App，快速落地物联网项目和产品。

## 特性

- ⚡️ 简单，简单，简单！填写几个参数就可以烧录运行，设备快速上线。
- 📊 可实现传感器数据上报和控制下发，利用各种外设发挥你的想象空间。
- 🔗 封装了 ThingsCloud 接入协议，只需调用函数和绑定事件，就可以实现设备和云平台双向通信。
- 🎯 支持自定义Topic，通过云平台设备类型的自定义数据流。
- 🏭 支持一型一密/自动注册设备，用于量产设备。
- ✨ 享受 ThingsCloud 云平台所有特性，一键生成物联网 SaaS 后台，以及用户 App，快速落地物联网项目和产品。


## 支持模组

- Air780E 全系列（包括 Air780EG、Air780EP、Air780EPM 等）
- Air600E

对于 Air724/820 系列模组，请移步到 [luat-thingscloud-libs](https://github.com/IoT-ThingsCloud/luat-thingscloud-libs)

## ThingsCloud 准备工作

- 登录 [ThingsCloud 控制台](https://www.thingscloud.xyz)。
- 创建项目，可选择免费版。
- 创建设备，进入设备详情页的【连接】页面，复制设备证书和MQTT接入点地址。请勿泄露你的设备证书。

![](https://img-1300291923.cos.accelerate.myqcloud.com/articles/2023/20230308225114_a177c9cd9a38216ca9872f51c8c31f9f.png)

更多详细介绍，可参考以下文档：

- [快速上手控制台](https://www.thingscloud.xyz/docs/guide/quickstart/signin-console.html)
- [如何获得设备证书？](https://www.thingscloud.xyz/docs/guide/connect-device/device-certificate.html)
- [ThingsCloud MQTT 接入文档](https://docs.thingscloud.xyz/guide/connect-device/mqtt.html)


## 使用方法

### 引用库文件

在主程序中引入库文件：

```lua
local ThingsCloud = require "ThingsCloud"
```

然后将 `libs/` 下的库文件添加到项目的脚本列表中。

### 一机一密连接方式

在代码顶部定义设备连接参数：

```lua
-- 一机一密方式
-- ProjectKey
local projectKey = ""
-- AccessToken
local accessToken = ""
-- MQTT 接入点，只需主机名部分
local host = ""
```


在代码中连接 ThingsCloud 云平台：

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


### 一型一密连接方式


在代码顶部定义设备连接参数：

```lua
-- ProjectKey
local projectKey = ""
-- MQTT 接入点，只需主机名部分
local host = ""
-- HTTP 接入点，为设备提供证书获取服务。设备通过 DeviceKey 获取 AccessToken
local apiEndpoint = ""
```

在代码中连接 ThingsCloud 云平台：


```lua
-- 设备接入云平台的初始化逻辑，在独立协程中完成
sys.taskInit(function()
    -- 连接云平台，支持判断网络可用性、MQTT自动重连
    -- 这里采用了设备一型一密方式，为项目下所有设备烧录相同的固件。
    ThingsCloud.connect({
        host = host,
        projectKey = projectKey,
        apiEndpoint = apiEndpoint,
    })
end)
```



### 烧录固件


使用 Luatools 烧录底层固件和脚本，底层示例固件在 core/ 目录下，您可以根据需要前往合宙官网下载最新的底层固件。

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230309183140_8791097d56f2594bb981b675615b3842.png)



## 示例项目

代码仓库中 examples 目录下有完整的示例代码，[点此进入示例目录](https://github.com/IoT-ThingsCloud/luatos-thingscloud-sdk/tree/main/examples)。

### 连接云平台

#### 普通连接（一机一密）

[01.ThingsCloud_Connect/basic_connect](examples/01.ThingsCloud_Connect/basic_connect)

#### 动态获取证书（一型一密）

[01.ThingsCloud_Connect/fetch_certificate](examples/01.ThingsCloud_Connect/fetch_certificate)

#### 自动创建设备+动态获取证书（一型一密）

[01.ThingsCloud_Connect/fetch_certificate_auto_create](examples/01.ThingsCloud_Connect/fetch_certificate_auto_create)

### 和云平台双向通信

#### 属性上报

[02.ThingsCloud_Communicate/attributes_report](examples/02.ThingsCloud_Communicate/attributes_report)

#### 接收下发属性

[02.ThingsCloud_Communicate/attributes_push](examples/02.ThingsCloud_Communicate/attributes_push)

#### 获取云端属性

[02.ThingsCloud_Communicate/attributes_get](examples/02.ThingsCloud_Communicate/attributes_get)

#### 事件上报

[02.ThingsCloud_Communicate/event_report](examples/02.ThingsCloud_Communicate/event_report)

#### 接收下发命令

[02.ThingsCloud_Communicate/command_send](examples/02.ThingsCloud_Communicate/command_send)

#### 自定义数据流

[02.ThingsCloud_Communicate/custom_data](examples/02.ThingsCloud_Communicate/custom_data)

### 综合示例

#### 透传 DTU（支持二进制通信，也可用于 RS485 透传）

[10.IoT_Tutorials/uart_dtu](examples/10.IoT_Tutorials/uart_dtu)

#### 透传 DTU（JSON 透传）

[10.IoT_Tutorials/uart_json](examples/10.IoT_Tutorials/uart_json)

#### 透传 DTU（支持 GPS 模块）

[10.IoT_Tutorials/air780eg_dtu_json](examples/10.IoT_Tutorials/air780eg_dtu_json)

#### GPS 上报

[10.IoT_Tutorials/air780eg_gps_tracker](examples/10.IoT_Tutorials/air780eg_gps_tracker)

#### 云平台控制 GPIO 输出 —— 网络继电器

[10.IoT_Tutorials/gpio_out](examples/10.IoT_Tutorials/gpio_out)

#### SHT30 传感器上报

[10.IoT_Tutorials/sht30_sensor](examples/10.IoT_Tutorials/sht30_sensor)

#### 云平台控制 PWM 输出 —— 电机调速

[10.IoT_Tutorials/pwm_out](examples/10.IoT_Tutorials/pwm_out)

#### ADC 模拟量采集

[10.IoT_Tutorials/adc_sensor](examples/10.IoT_Tutorials/adc_sensor)

#### OTA 升级 - 云平台主动推送模式

[10.IoT_Tutorials/ota_push](examples/10.IoT_Tutorials/ota_push)

#### OTA 升级 - 设备检查新版本

[10.IoT_Tutorials/ota_check](examples/10.IoT_Tutorials/ota_check)

#### OTA 升级 - 主控 MCU 通过 Air780E 检查新版本并下载固件

[10.IoT_Tutorials/ota_check_uart_mcu](examples/10.IoT_Tutorials/ota_check_uart_mcu)


更多示例代码完善中，欢迎你的建议，也欢迎提交贡献。



## 关于 ThingsCloud

ThingsCloud 是物联网设备统一接入平台和低代码应用开发平台。可以帮助任何需要数字化改造的行业客户，在极短的时间内搭建物联网应用，并适应不断变化的发展需求。ThingsCloud 支持智能传感器、执行器、控制器、智能硬件等设备接入，支持 MQTT/HTTP/TCP/Modbus/LoRa/Zigbee/WiFi/BLE 等通信协议，实现数据采集、分析、监控，还可以灵活配置各种规则，生成项目应用 SaaS 和用户应用 App，这一切无需任何云端代码开发。

- 官网：https://www.thingscloud.xyz/
- 控制台：https://console.thingscloud.xyz/
- 教程：https://docs.thingscloud.xyz/tutorials/
- 使用文档：https://docs.thingscloud.xyz
- 设备接入：https://docs.thingscloud.xyz/guide/connect-device/
- 博客：https://www.thingscloud.xyz/blog/
- B站：https://space.bilibili.com/1953347444


![articles/2023/20230112114634_afd61232cd029fca77eaebe67e12beaf.png](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230112114634_afd61232cd029fca77eaebe67e12beaf.png)

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230303162529_7d47018b2466053ef3af13dcfd23b703.png)

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230303194054_fe9320028f7b499a18893b7a0d25b3c7.png)

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230303163508_4b2e3b2052e282bcf2e36143fe90d101.png)

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230303164617_c0f98e1ae66b5987aba3408faf86ac1d.png)

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/articles/2023/20230303163103_40fe1d013e8d1d665bdd3cd0ae42adc0.png)

### 技术支持

联系 ThingsCloud 技术支持

![](https://img-1300291923.cos.ap-beijing.myqcloud.com/service/support-qrcode-wlww-1208.png)