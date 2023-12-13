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

local function updateOTA(ota)
    log.info("Download and update OTA...")
    local code, headers, body = http.request("GET", ota.url, nil, nil, {
        fota = true,
        timeout = 3000
    }).wait()
    log.info("update OTA resp -> ", code, headers, body)
    local ret
    if code == 200 or code == 206 then
        if body == 0 then
            ret = 4
        else
            ret = 0
        end
    elseif code == -4 then
        ret = 1
    elseif code == -5 then
        ret = 3
    else
        ret = 4
    end
    return ret
end

-- 设备成功连接云平台后，触发该函数
local function onConnect(result)
    if result then
        -- 当设备连接成功后

        -- 例如：切换设备的LED闪烁模式，提示用户设备已正常连接。

        -- 连接后立即上报 OTA 新版本检查事件
        ThingsCloud.reportEvent({
            method = "otaCheck",
            params = {}
        })

    end
end

-- 设备接收到云平台下发的命令时，触发该函数
local function onCommandSend(command)
    log.info("recv command send", json.encode(command))
    if command.method == "otaUpgrade" then
        -- 参考 ThingsCloud OTA 文档：https://www.thingscloud.xyz/docs/guide/maintain/ota.html
        local params = command.params or {}
        if params.upgrade then

            sys.taskInit(function()
                local ota_result = updateOTA(params)
                -- 完成任务后，回复平台，上报OTA升级结果
                ThingsCloud.replyCommand({
                    method = "otaUpgrade",
                    params = {
                        ota_result = ota_result
                    },
                    id = command.id
                })
                if ota_result == 0 then
                    -- 升级成功，等待片刻，重启模组
                    sys.wait(3000)
                    ThingsCloud.disconnect()
                    rtos.reboot()
                end
            end)
        end

    elseif command.method == "restart" then
        -- 调用模组的重启指令
        ThingsCloud.disconnect()
        rtos.reboot()
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
    ThingsCloud.on("command_send", onCommandSend)

end)

-- 定时主动向云平台检查是否有新版本固件
-- 文档参考：https://www.thingscloud.xyz/docs/guide/maintain/ota.html
sys.taskInit(function()
    while true do
        -- 此处要判断是否已连接成功
        if ThingsCloud.isConnected() then

            -- 定期上报 OTA 新版本检查事件
            ThingsCloud.reportEvent({
                method = "otaCheck",
                params = {}
            })

            -- 如果存在新版本，云平台会下发 otaUpgrade 命令，在上边的函数中处理

        end
        -- 12 个小时检查一次新版本
        sys.wait(1000 * 3600 * 12)
    end
end)

