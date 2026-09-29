extends Area2D

var speed = 500
var direction = 1


func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()


func _physics_process(delta):
	position.x += speed * direction * delta


func _on_body_entered(body):
	body.queue_free()
	queue_free()
