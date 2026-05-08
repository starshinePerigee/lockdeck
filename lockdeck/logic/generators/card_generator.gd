class_name PickGenerator

static func get_random_base_card() -> CardSpec:
	var template = PickTemplateData.ValidPicks.pick_random()
	var spec = CardSpec.new(template)
	return spec
