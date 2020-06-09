extends Node

export(String) var title = "Perlin Worms"

func _process(_delta):
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))
