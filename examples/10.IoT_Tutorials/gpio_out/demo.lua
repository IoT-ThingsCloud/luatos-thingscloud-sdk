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

-- PWM 引脚定义
local PWM_ID = 1
-- PWM 状态全局变量
local pwm_state = false -- 是否开启
local pwm_freq = 1000 -- 频率（Hz）
local pwm_duty = 100 -- 占空比0-100

-- 设备成功连接云平台后，触发该函数
local function onConnect(result)
    if result then
        -- 当设备连接成功后

        -- 例如：切换设备的LED闪烁模式，提示用户设备已正常连接。

        sys.wait(1000)
        -- 向云平台请求设备属性，例如读取配置信息。
        -- 参数是 table 数组，用来指定希望读取的属性名称，如果数组为空，可请求所有属性
        -- 云平台回复属性值，在事件 attributes_get_response 的回调函数中接收
        ThingsCloud.getAttributes({})

    end
end

-- 设备开机时获取最新的状态，用来初始化设备。
-- 设备向云平台发送读取云端属性后，接收到云平台下发的命令时，触发该函数
-- response 是table结构的返回数据
-- responseId 作为请求标识，通常可以不使用
local function onAttributesGetResponse(response, responseId)
    log.info("attributes get response", json.encode(response), responseId)

    -- 获得云平台回复的属性值，实现相应的自定义逻辑
    if response.result == 1 then
        local attributes = response.attributes or {}
        pwm_state = attributes.pwm_state or false
        pwm_freq = attributes.pwm_freq or 1000
        pwm_duty = attributes.pwm_duty or 100
        if pwm_state == true then
            -- 启动 PWM
            pwm.open(PWM_ID, pwm_freq, pwm_duty)
        end
    end

end

-- 设备接收到云平台下发的属性时，触发该函数
local function onAttributesPush(attributes)
    log.info("recv attributes push", json.encode(attributes))

    pwm_state = attributes.pwm_state or false
    pwm_freq = attributes.pwm_freq or 1000
    pwm_duty = attributes.pwm_duty or 100
    if pwm_state == true then
        -- 启动 PWM
        pwm.open(PWM_ID, pwm_freq, pwm_duty)
    else
        pwm.close(PWM_ID)
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
    ThingsCloud.on("attributes_push", onAttributesPush)
    ThingsCloud.on("attributes_get_response", onAttributesGetResponse)

end)

