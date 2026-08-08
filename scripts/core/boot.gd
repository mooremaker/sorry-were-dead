extends Control

func _ready() -> void:
    var renderer := str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "unknown"))
    var platform := OS.get_name()
    $Center/Runtime.text = "PLATFORM: %s   •   RENDERER: %s   •   INTERNAL: 640x360" % [platform, renderer]
    print("Sorry We're Dead foundation booted successfully.")
    print("Platform: ", platform)
    print("Renderer: ", renderer)
    print("Offline play starts authoritative by default in Godot's MultiplayerAPI.")
