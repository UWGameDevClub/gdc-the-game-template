extends  MicroGameCreditDisplay

@export var thumbnail : TextureRect
@export var title : Label
@export var authors : Label
@export var description : Label

func init(info : MicroGameInfo):
	thumbnail.texture = info.thumbnail
	title.text = info.title
	authors.text = info.authors
	description.text = info.description
