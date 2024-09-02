-- 引入 ThingsCloud 接入库
-- 接入协议参考：ThingsCloud MQTT 接入文档 https://docs.thingscloud.xyz/guide/connect-device/mqtt.html
local ThingsCloud = require "ThingsCloud"

-- 进入 ThingsCloud 控制台：https://www.thingscloud.xyz
-- 创建设备，进入设备详情页的【连接】页面，复制设备证书和MQTT接入点地址。请勿泄露你的设备证书。
-- ProjectKey
local projectKey = ""
-- MQTT 接入点，只需主机名部分
local host = ""
-- HTTP 接入点，为设备提供证书获取服务。设备通过 DeviceKey 获取 AccessToken
local apiEndpoint = ""
-- TypeKey，自动创建设备必须指定设备类型，在设备类型的设置中开启允许自动创建设备，并复制 TypeKey
local typeKey = ""

-- 设备成功连接云平台后，触发该函数
local function onConnect(result)
    if result then
        -- 当设备连接成功后

        -- 例如：切换设备的LED闪烁模式，提示用户设备已正常连接。

    end
end

-- 设备接入云平台的初始化逻辑，在独立协程中完成
sys.taskInit(function()
    -- 连接云平台，内部支持判断网络可用性、MQTT自动重连
    -- 这里采用了设备一型一密方式，为项目下所有设备烧录相同的固件。
    ThingsCloud.connect({
        host = host,
        projectKey = projectKey,
        apiEndpoint = apiEndpoint,
        typeKey = typeKey,
    })

    -- 注册各类事件的回调函数，在回调函数中编写所需的硬件端操作逻辑
    ThingsCloud.on("connect", onConnect)

end)

