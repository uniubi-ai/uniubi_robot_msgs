# Protocol Notes

**English** | [简体中文](protocol_notes.zh-CN.md)

This repository is the source of DDS IDL and ROS 2 message/service definitions. It does not define the C++ SDK POD structures used internally by `uniubi_robot_sdk`.

## IDL is the wire contract

When implementing a DDS client or generating ROS 2 interfaces, treat `idl/` as the source of truth for the wire contract. The ROS 2 package under `ros2/` is generated from the IDL mappings and follows ROS 2 field-naming conventions. For example, `clientId` maps to `client_id`, and `stickLX` maps to `stick_l_x`.

Do not infer the DDS wire layout from `uniubi_robot_sdk/include/uniubi/robot_sdk/MotionSdkProtocol.h`. SDK structures are API/runtime PODs, not DDS wire structures.

`MotionOdometry` is defined in `SensorObserved.idl` and published as `SensorObserved_.odom` within the full sensor observation. The IDL field `yawSpeed` maps to `yaw_speed` in the ROS 2 `MotionOdometry.msg`. `position[2]` and `velocity[2]` are reserved and currently always `0`. Odometry is valid only in Walk mode. When Walk mode ends, the final value for that interval is retained and `valid` becomes false. Entering Walk mode again establishes a new origin and increments `epoch`.

## Known SDK POD differences

`MotorHeader` is the structure most likely to be confused across layers:

| Layer | Fields |
|---|---|
| DDS IDL / ROS 2 | `uint32 limbsNo` / `jointNo` (`limbs_no` / `joint_no` in ROS 2) |
| C++ SDK POD | `uint16 limbNo` / `uint16 jointNo` |

Both identify a motor, but they belong to different ABI/protocol contracts. When bridging SDK observations to DDS or ROS 2 messages, convert the fields explicitly instead of reusing the memory layout.

## `System.srv` field boundary

`ros2/srv/System.srv` is the ROS 2 service interface definition and describes the request and response fields carried on the ROS 2 side.

The field boundary is:

- `Header.msg` comes from `Request.idl` and contains `client_id` / `request_id` for message types that include a Header and for checking IDL mappings.
- `System.srv` does not contain a `Header` field. Do not treat `Header.msg` as part of the `System.srv` request.
- Both the `System.srv` request and response contain `device_id`. In multi-device environments, set the target device SN and verify the `device_id` in the response.

This repository maintains `.srv` / `.msg` field definitions and IDL mapping boundaries; it does not provide business-level call wrappers. See `uniubi_ros2` for ROS 2 integration examples. The interface package published by this repository remains authoritative for field definitions.
