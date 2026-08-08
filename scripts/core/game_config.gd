class_name GameConfig
extends RefCounted

# Initial pacing TARGETS, not permanent rules.
const TARGET_DAY_REAL_SECONDS: float = 60.0 * 60.0
const TARGET_SHIFT_REAL_SECONDS: float = 20.0 * 60.0

# Multiplayer foundation.
const DEFAULT_MAX_PLAYERS: int = 4
const DEFAULT_SERVER_PORT: int = 9080

# Pixel-art internal canvas.
const INTERNAL_RESOLUTION: Vector2i = Vector2i(640, 360)
