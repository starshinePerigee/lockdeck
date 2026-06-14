class_name PickGenerator

static func get_random_base_card() -> CardSpec:
	var template: PickTemplates = PickTemplates.valid_templates.pick_random()
	var spec := CardSpec.from_template(template)
	return spec
