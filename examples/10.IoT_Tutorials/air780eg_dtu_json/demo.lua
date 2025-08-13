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
-- 如果采用一型一密方式，参考示例 01.ThingsCloud_Connect/fetch_certificate

-- 初始化和主控通信的 UART1
local UART_MCU_ID = 1
uart.setup(UART_MCU_ID, -- 串口id
115200, -- 波特率
8, -- 数据位
1 -- 停止位
)

uart.on(UART_MCU_ID, "receive", function(id, len)
    local data = ""
    repeat
        data = uart.read(id, len)
        if #data > 0 then
            log.info("uart", "receive", id, #data, data)
            -- 将串口收到的 JSON 数据，作为属性上报到云平台。注意 data 必须是 JSON 格式文本。
            ThingsCloud.publish("attributes", data)
        end
    until data == ""
end)

-- 初始化 GPS UART2，适用于 Air780EG，或 Air780E 连接独立的 GPS 模块，都使用 UART2 连接 GPS
local UART_GPS_ID = 2
sys.taskInit(function()
    uart.setup(UART_GPS_ID, 9600)

    log.info("GPS", "start")
    pm.power(pm.GPS, true)

    -- 读取 UART 数据后调用解析函数
    uart.on(UART_GPS_ID, "recv", function(id, len)
        while 1 do
            local data = uart.read(id, 1024)
            if data and #data > 1 then
                -- log.info(data)
                libgnss.parse(data)
            else
                break
            end
        end
    end)

    sys.subscribe("GNSS_STATE", function(event, ticks)
        -- event取值有 
        -- FIXED 定位成功
        -- LOSE  定位丢失
        -- ticks是事件发生的时间,一般可以忽略
        log.info("gnss", "state", event, ticks)
    end)

    while true do
        log.info("GPS", "isFix", libgnss.isFix(), "loc", libgnss.getIntLocation(), "rmc", json.encode(libgnss.getRmc(2)))
        sys.wait(1000 * 2)
    end

end)

-- 设备成功连接云平台后，触发该函数
local function onConnect(result)
    if result then
        -- 当设备连接成功后

        -- 例如：切换设备的LED闪烁模式，提示用户设备已正常连接。

    end
end

-- 设备接收到云平台下发的属性时，触发该函数
local function onAttributesPush(attributes)
    log.info("recv attributes push", json.encode(attributes))

    -- 将云平台下发的属性 JSON，发送到主控
    uart.write(UART_MCU_ID, json.encode(attributes))
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
    ThingsCloud.on("attributes_push", onAttributesPush)

end)

-- 在独立的协程中上报数据到云平台，可实现固定时间间隔的上报。
-- 上报的数据，可在其它协程中读取，例如读取串口传感器数据
sys.taskInit(function()

    while true do
        -- 此处要判断是否已连接成功
        if ThingsCloud.isConnected() then

            local attributes = {}
            attributes["gps_connected"] = libgnss.isFix()
            attributes["gps_rmc"] = libgnss.getRmc(2)
            attributes["gps_gsv"] = libgnss.getGsv()
            attributes["gps_gsa"] = libgnss.getGsa(2)
            attributes["gps_vtg"] = libgnss.getVtg(2)
            attributes["gps_zda"] = libgnss.getZda()
            attributes["gps_gga"] = libgnss.getGga(2)
            attributes["gps_gll"] = libgnss.getGll(2)

            local gga = libgnss.getGga(2)
            if libgnss.isFix() and type(gga) == "table" and gga.latitude ~= 0 and gga.longitude ~= 0 then
                -- 如果GPS定位成功，上报 ThingsCloud 位置类型属性
                attributes["location_gps"] = {
                    lat = gga.latitude,
                    lng = gga.longitude
                }
            end

            ThingsCloud.reportAttributes(attributes)

        end
        -- 上报间隔时间为60秒
        -- 使用 ThingsCloud 免费版时，数据上报频率不要低于1分钟，否则可能会被断开连接，造成设备通信不稳定
        sys.wait(1000 * 60)
    end

end)

sys.taskInit(function()

    while true do
        -- 此处要判断是否已连接成功
        if ThingsCloud.isConnected() then

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
        -- 上报间隔时间为5分钟
        -- 使用 ThingsCloud 免费版时，数据上报频率不要低于1分钟，否则可能会被断开连接，造成设备通信不稳定
        sys.wait(1000 * 60 * 5)
    end

end)

