# Walk model planar odometry. position[2] and velocity[2] are reserved and always zero.
float32[3] position
float32[3] velocity
float32 yaw
float32 yaw_speed
uint64 timestamp_us
uint32 epoch
bool valid
