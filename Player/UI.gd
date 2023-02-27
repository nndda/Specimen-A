extends CanvasLayer

func SkillTween_AnimHide() -> void:
	$Control/Skills/Tween.interpolate_property(
		$Control/Skills, "margin_top",
		$Control/Skills.margin_top,
		-48,
		0.55, Tween.TRANS_SINE, Tween.EASE_OUT
		)
	$Control/Skills/Tween.start()
func SkillTween_AnimShow() -> void:
	$Control/Skills/Tween.interpolate_property(
		$Control/Skills, "margin_top",
		$Control/Skills.margin_top,
		5,
		0.35, Tween.TRANS_SINE, Tween.EASE_OUT
		)
	$Control/Skills/Tween.start()

func SkillSwitched() -> void:
	SkillTween_AnimShow()
	$Control/Skills/AnimationPlayer/Visibility.start(1.5)

func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					SkillSwitched()
					glbl.skill_current += 1
				BUTTON_WHEEL_DOWN:
					SkillSwitched()
					glbl.skill_current -= 1
func _process(_delta):
	$Control/HealthBar.rect_scale.x = range_lerp(glbl.health, 0, 100, 0, 1)
	if glbl.health < 80:
		$Control/HealthBar/AnimationPlayer.seek(0,true)
	
	if Input.is_action_just_pressed("NextSkill"):
		SkillSwitched()
		glbl.skill_current += 1
	if Input.is_action_just_pressed("PrevSkill"):
		SkillSwitched()
		glbl.skill_current -= 1

	$Control/Skills/DischargeShrapnel.visible							= glbl.skills_discovered >= glbl.skill.DischargeShrapnel
	$Control/Skills/EMPBurst.visible									= glbl.skills_discovered >= glbl.skill.EMPBurst
	$Control/Skills/SynthesizeAcids.visible								= glbl.skills_discovered >= glbl.skill.SynthesizeAcids

	$Control/Skills/DischargeShrapnel/Hover.visible						= glbl.skill_current == glbl.skill.DischargeShrapnel
	$Control/Skills/EMPBurst/Hover.visible								= glbl.skill_current == glbl.skill.EMPBurst
	$Control/Skills/SynthesizeAcids/Hover.visible						= glbl.skill_current == glbl.skill.SynthesizeAcids

	$Control/Skills/DischargeShrapnel.modulate							= Color("e50000") if $Control/Skills/DischargeShrapnel/Hover.visible else Color("ffffff")
	$Control/Skills/EMPBurst.modulate									= Color("e50000") if $Control/Skills/EMPBurst/Hover.visible else Color("ffffff")
	$Control/Skills/SynthesizeAcids.modulate							= Color("e50000") if $Control/Skills/SynthesizeAcids/Hover.visible else Color("ffffff")

	$Control/Skills/DischargeShrapnel/CapBar/ColorRect.rect_scale.x		= range_lerp(glbl.shrapnel_current,0,1,0,1)
	$Control/Skills/EMPBurst/CapBar/ColorRect.rect_scale.x				= range_lerp(glbl.emp_charge,0,1,0,1)
	$Control/Skills/SynthesizeAcids/CapBar/ColorRect.rect_scale.x		= range_lerp(glbl.acid,0,1,0,1)

	match glbl.skill_current:
		glbl.skill.none:
			$Control/Skills/Label2/Label.text = "Dash"
		glbl.skill.DischargeShrapnel:
			$Control/Skills/Label2/Label.text = "Discharge Shrapnel"
		glbl.skill.EMPBurst:
			$Control/Skills/Label2/Label.text = "EMP Burst"
		glbl.skill.SynthesizeAcids:
			$Control/Skills/Label2/Label.text = "Synthesize Acids"



func _on_SkillUI_Visibility_timeout():
	SkillTween_AnimHide()
