-- 引入 ThingsCloud 接入库
-- 接入协议参考：ThingsCloud MQTT 接入文档 https://docs.thingscloud.xyz/guide/connect-device/mqtt.html
local ThingsCloud = require "ThingsCloud"

-- 进入 ThingsCloud 控制台：https://www.thingscloud.xyz
-- 创建设备，进入设备详情页的【连接】页面，复制设备证书和MQTT接入点地址。请勿泄露你的设备证书。
-- ProjectKey
local projectKey = ""
-- AccessToken
local accessToken = ""
-- MQTT 接入点，只需主机名部分
local host = ""

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
    -- 这里采用了设备一机一密方式，需要为每个设备固件单独写入证书。另外也支持一型一密，相同设备类型下的所有设备使用相同固件。
    ThingsCloud.connect({
        host = host,
        projectKey = projectKey,
        accessToken = accessToken
    })

    -- 注册各类事件的回调函数，在回调函数中编写所需的硬件端操作逻辑
    ThingsCloud.on("connect", onConnect)

end)

-- 在独立的协程中上报数据到云平台，可实现固定时间间隔的上报。
-- 上报的数据，可在其它协程中读取，例如读取串口传感器数据
sys.taskInit(function()
    while true do
        -- 此处要判断是否已连接成功
        if ThingsCloud.isConnected() then

            -- 上报属性，这里举例模拟一些数据
            ThingsCloud.reportAttributes({
                imei = mobile.imei(),
                imsi = mobile.imsi(),
                csq = mobile.csq(),
                iccid = mobile.iccid(),
                rssi = mobile.rssi(),
                rsrq = mobile.rsrq(),
                rsrp = mobile.rsrp(),
                snr = mobile.snr(),
                simid = mobile.simid()
            })
        end
        -- 上报间隔时间为60秒
        -- 使用 ThingsCloud 免费版时，数据上报频率不要低于1分钟，否则可能会被断开连接，造成设备通信不稳定
        sys.wait(1000 * 60)
    end
end)
