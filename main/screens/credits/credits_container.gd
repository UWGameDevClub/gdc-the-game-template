extends Control

@onready var credit_name_container_scn : PackedScene = preload("res://main/screens/credits/credit_name_container.tscn")
@onready var credit_parent := $MarginContainer/ScrollContainer/VBoxContainer

@export var credits : Array[_CreditResource]
@export var is_alphabetical : bool = false

func _ready():
	if is_alphabetical: sort_credits()
	for c in credits:
		create_credit_container(c)

func sort_credits():
	credits.sort_custom(func(x:_CreditResource, y:_CreditResource):
		return x.credit_name < y.credit_name)

func create_credit_container(cred_res : _CreditResource):
	var cc : _CreditNameContainer = credit_name_container_scn.instantiate()
	credit_parent.add_child(cc)
	cc.credit_name = cred_res.credit_name
	cc.info = cred_res.description
	cc.link = cred_res.link
