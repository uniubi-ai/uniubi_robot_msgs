# 协议注意事项

本仓是 DDS IDL 与 ROS 2 消息 / 服务定义的来源，不定义 `uniubi_robot_sdk` 内部使用的 C++ SDK POD 结构。

## IDL 是 wire contract

实现 DDS 客户端或生成 ROS 2 接口时，以 `idl/` 作为 wire contract 源头。`ros2/` 下的 ROS 2 package 按 IDL 映射生成，并遵循 ROS 2 字段命名规范，例如 `clientId` 映射为 `client_id`，`stickLX` 映射为 `stick_l_x`。

不要从 `uniubi_robot_sdk/include/uniubi/robot_sdk/MotionSdkProtocol.h` 反推 DDS wire layout。SDK 结构是 API / runtime POD，不是 DDS wire struct。

## 已知 SDK POD 差异

`MotorHeader` 是最容易混用的结构：

| 层级 | 字段 |
|---|---|
| DDS IDL / ROS 2 | `uint32 limbsNo` / `uint32 jointNo` (`limbs_no` / `joint_no` in ROS 2) |
| C++ SDK POD | `uint16 limbNo` / `uint16 jointNo` |

两者都描述电机身份，但属于不同 ABI / 协议契约。把 SDK 观测量桥接到 DDS 或 ROS 2 消息时，应显式转换字段，不要直接混用内存结构。

## System.srv 字段边界

`ros2/srv/System.srv` 是 ROS 2 service 接口定义，描述 ROS 2 侧承载的请求 / 响应字段。

字段边界如下：

- `Header.msg` 来自 `Request.idl`，包含 `client_id` / `request_id`，用于包含 Header 的消息类型和 IDL 映射核对。
- `System.srv` 不含 `Header` 字段；不要把 `Header.msg` 当作 `System.srv` 的请求字段。
- `System.srv` 请求和响应都包含 `device_id`；多设备场景应填写目标设备 SN，并核对响应中的 `device_id`。

本仓维护 `.srv` / `.msg` 字段定义和 IDL 映射边界，不承载业务调用封装。ROS 2 示例接入流程见 `uniubi_ros2`，字段定义仍以本仓发布的接口包为准。
