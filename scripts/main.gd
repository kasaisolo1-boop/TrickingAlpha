extends Node3D

var player: Node3D
var rotating = false
var score = 0
var combo = 0
var jump_height = 1.5
var move_speed = 4.0
var move_input = Vector2.ZERO
var camera: Camera3D
var camera_offset = Vector3(5, 4, 7)

var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var current_map = "Земля"
var ground: MeshInstance3D
var track_marks: Node3D
var game_started = false

var tricks = {
    "BACKFLIP": Vector3(360, 0, 0),
    "FRONTFLIP": Vector3(-360, 0, 0),
    "SIDEFLIP": Vector3(0, 0, 360),
    "TWIST": Vector3(0, 360, 0),
    "CORK": Vector3(360, 360, 0)
}

func _ready():
    set_process(true)
    create_world()
    create_player()
    create_arena()
    create_camera()
    create_ui()

func _process(delta):
    if not game_started or player == null or rotating:
        return

    var direction = Vector3(move_input.x, 0, move_input.y)
    player.position += direction * move_speed * delta

    if camera != null:
        camera.position = player.position + camera_offset
        camera.look_at(player.position + Vector3(0, 0.8, 0))

func create_world():
    ground = MeshInstance3D.new()
    ground.name = "Ground"
    var mesh = PlaneMesh.new()
    mesh.size = Vector2(100, 100)
    ground.mesh = mesh
    add_child(ground)
    track_marks = Node3D.new()
    track_marks.name = "TrackMarks"
    add_child(track_marks)
    update_map_material()

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55, -30, 0)
    light.shadow_enabled = true
    add_child(light)



func create_player():
    player = Node3D.new()
    player.position.y = 1
    player.name = "Player"
    add_child(player)

    var body = CapsuleMesh.new()
    body.radius = 0.3
    body.height = 1.0
    make_part(player, body, Vector3(0, 0.05, 0),
        Vector3.ONE, Color(0.12, 0.3, 0.9))

    var head = SphereMesh.new()
    head.radius = 0.23
    head.height = 0.46
    make_part(player, head, Vector3(0, 0.78, 0),
        Vector3.ONE, Color(0.85, 0.65, 0.48))

    left_arm = create_limb(
        Vector3(-0.34, 0.4, 0),
        Vector3(0, -0.3, 0),
        Color(0.12, 0.3, 0.9)
    )

    right_arm = create_limb(
        Vector3(0.34, 0.4, 0),
        Vector3(0, -0.3, 0),
        Color(0.12, 0.3, 0.9)
    )

    left_leg = create_limb(
        Vector3(-0.16, -0.4, 0),
        Vector3(0, -0.3, 0),
        Color(0.12, 0.12, 0.18)
    )

    right_leg = create_limb(
        Vector3(0.16, -0.4, 0),
        Vector3(0, -0.3, 0),
        Color(0.12, 0.12, 0.18)
    )


func create_limb(pos: Vector3, mesh_pos: Vector3, color: Color) -> Node3D:
    var pivot = Node3D.new()
    pivot.position = pos
    player.add_child(pivot)

    var mesh = CapsuleMesh.new()
    mesh.radius = 0.11
    mesh.height = 0.8

    make_part(pivot, mesh, mesh_pos, Vector3.ONE, color)
    return pivot

func make_part(parent: Node3D, mesh: Mesh, pos: Vector3,
        scale_value: Vector3, color: Color):
    var part = MeshInstance3D.new()
    part.mesh = mesh
    part.position = pos
    part.scale = scale_value

    var material = StandardMaterial3D.new()
    material.albedo_color = color
    part.material_override = material

    parent.add_child(part)

func create_camera():
    camera = Camera3D.new()
    camera.position = camera_offset
    add_child(camera)
    camera.current = true
    camera.look_at(Vector3(0, 1, 0))

func create_ui():
    var ui = CanvasLayer.new()
    ui.name = "CanvasLayer"
    add_child(ui)

    var title = Label.new()
    title.name = "Title"
    title.text = "TRICKING ALPHA"
    title.position = Vector2(25, 20)
    title.add_theme_font_size_override("font_size", 28)
    ui.add_child(title)

    var score_label = Label.new()
    score_label.name = "Score"
    score_label.text = "SCORE: 0"
    score_label.position = Vector2(25, 65)
    score_label.add_theme_font_size_override("font_size", 22)
    ui.add_child(score_label)

    var map_button = Button.new()
    map_button.name = "Button"
    map_button.text = "КАРТА: " + current_map
    map_button.position = Vector2(230, 20)
    map_button.size = Vector2(190, 48)
    map_button.pressed.connect(switch_map)
    ui.add_child(map_button)

    var left = Button.new()
    left.text = "◀"
    left.position = Vector2(25, 570)
    left.size = Vector2(65, 65)
    left.button_down.connect(func(): move_input.x = -1)
    left.button_up.connect(func(): move_input.x = 0)
    ui.add_child(left)

    var right = Button.new()
    right.text = "▶"
    right.position = Vector2(165, 570)
    right.size = Vector2(65, 65)
    right.button_down.connect(func(): move_input.x = 1)
    right.button_up.connect(func(): move_input.x = 0)
    ui.add_child(right)

    var forward = Button.new()
    forward.text = "▲"
    forward.position = Vector2(95, 500)
    forward.size = Vector2(65, 65)
    forward.button_down.connect(func(): move_input.y = -1)
    forward.button_up.connect(func(): move_input.y = 0)
    ui.add_child(forward)

    var backward = Button.new()
    backward.text = "▼"
    backward.position = Vector2(95, 640)
    backward.size = Vector2(65, 65)
    backward.button_down.connect(func(): move_input.y = 1)
    backward.button_up.connect(func(): move_input.y = 0)
    ui.add_child(backward)

    var y = 130
    for trick in tricks:
        var button = Button.new()
        button.text = trick
        button.position = Vector2(25, y)
        button.size = Vector2(180, 48)
        button.pressed.connect(play_trick.bind(trick))
        ui.add_child(button)
        y += 58

    var menu = ColorRect.new()
    menu.name = "MainMenu"
    menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    menu.color = Color(0.015, 0.025, 0.07, 0.94)
    ui.add_child(menu)

    var menu_title = Label.new()
    menu_title.text = "TRICKING ALPHA"
    menu_title.set_anchors_preset(Control.PRESET_CENTER)
    menu_title.position = Vector2(-230, -130)
    menu_title.size = Vector2(460, 70)
    menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    menu_title.add_theme_font_size_override("font_size", 42)
    menu.add_child(menu_title)

    var subtitle = Label.new()
    subtitle.text = "THE ULTIMATE TRICKING GAME"
    subtitle.set_anchors_preset(Control.PRESET_CENTER)
    subtitle.position = Vector2(-220, -65)
    subtitle.size = Vector2(440, 35)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 18)
    menu.add_child(subtitle)

    var play = Button.new()
    play.text = "ИГРАТЬ"
    play.set_anchors_preset(Control.PRESET_CENTER)
    play.position = Vector2(-110, 10)
    play.size = Vector2(220, 65)
    play.add_theme_font_size_override("font_size", 26)
    play.pressed.connect(func():
        menu.queue_free()
        game_started = true
    )
    menu.add_child(play)


func play_trick(trick: String):
    if rotating:
        return

    rotating = true
    combo += 1

    var poses = {
        "BACKFLIP": [Vector3(-100, 0, -35), Vector3(-100, 0, 35),
                     Vector3(-65, 0, 0), Vector3(-65, 0, 0)],
        "FRONTFLIP": [Vector3(100, 0, -35), Vector3(100, 0, 35),
                      Vector3(65, 0, 0), Vector3(65, 0, 0)],
        "SIDEFLIP": [Vector3(-20, 0, -100), Vector3(-20, 0, 100),
                     Vector3(-30, 0, 0), Vector3(-30, 0, 0)],
        "TWIST": [Vector3(-70, 0, -70), Vector3(-70, 0, 70),
                  Vector3(-50, 0, 0), Vector3(-50, 0, 0)],
        "CORK": [Vector3(-90, 0, -100), Vector3(-90, 0, 100),
                 Vector3(-70, 0, 0), Vector3(-70, 0, 0)]
    }

    var pose = poses[trick]

    var tween = create_tween().set_parallel(true)

    tween.tween_property(player, "rotation_degrees",
        tricks[trick], 0.8)

    tween.tween_property(player, "position:y",
        jump_height, 0.4)

    tween.tween_property(left_arm, "rotation_degrees", pose[0], 0.4)
    tween.tween_property(right_arm, "rotation_degrees", pose[1], 0.4)
    tween.tween_property(left_leg, "rotation_degrees", pose[2], 0.4)
    tween.tween_property(right_leg, "rotation_degrees", pose[3], 0.4)

    await tween.finished

    var landing = create_tween().set_parallel(true)

    landing.tween_property(player, "rotation_degrees", Vector3.ZERO, 0.3)
    landing.tween_property(player, "position:y", 1.0, 0.3)

    landing.tween_property(left_arm, "rotation_degrees", Vector3.ZERO, 0.3)
    landing.tween_property(right_arm, "rotation_degrees", Vector3.ZERO, 0.3)
    landing.tween_property(left_leg, "rotation_degrees", Vector3.ZERO, 0.3)
    landing.tween_property(right_leg, "rotation_degrees", Vector3.ZERO, 0.3)

    await landing.finished

    score += 100 * combo
    get_node("CanvasLayer/Score").text = "SCORE: " + str(score)

    rotating = false

func switch_map():
    current_map = "Олимпийская дорожка" if current_map == "Земля" else "Земля"
    update_map_material()
    var button = get_node_or_null("CanvasLayer/Button")
    if button:
        button.text = "КАРТА: " + current_map

func update_map_material():
    var material = StandardMaterial3D.new()

    if current_map == "Земля":
        material.albedo_color = Color(0.12, 0.55, 0.18)
    else:
        material.albedo_color = Color(0.85, 0.22, 0.12)

    ground.material_override = material

    for child in track_marks.get_children():
        child.queue_free()

    if current_map == "Олимпийская дорожка":
        create_track_marks()


func create_track_marks():
    for x in [-2.0, 2.0, 0.0]:
        var line = MeshInstance3D.new()
        var box = BoxMesh.new()
        box.size = Vector3(0.08, 0.025, 24.0)
        line.mesh = box
        line.position = Vector3(x, 0.025, 0)
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color.WHITE
        line.material_override = mat
        track_marks.add_child(line)


func create_arena():
    # Трибуны
    for side in [-1, 1]:
        for row in range(5):
            var stand = MeshInstance3D.new()
            var mesh = BoxMesh.new()
            mesh.size = Vector3(12, 0.5, 1.0)
            stand.mesh = mesh
            stand.position = Vector3(side * 9, row * 0.65 + 0.3, -5 + row * 0.5)

            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.12, 0.16, 0.28)
            stand.material_override = mat
            add_child(stand)

    # Деревья
    for i in range(8):
        var tree = Node3D.new()
        tree.position = Vector3(-12 + i * 3.5, 0, -13)
        add_child(tree)

        var trunk = MeshInstance3D.new()
        var trunk_mesh = CylinderMesh.new()
        trunk_mesh.top_radius = 0.18
        trunk_mesh.bottom_radius = 0.28
        trunk_mesh.height = 2.0
        trunk.mesh = trunk_mesh
        trunk.position.y = 1.0

        var trunk_mat = StandardMaterial3D.new()
        trunk_mat.albedo_color = Color(0.3, 0.16, 0.07)
        trunk.material_override = trunk_mat
        tree.add_child(trunk)

        var leaves = MeshInstance3D.new()
        var leaves_mesh = SphereMesh.new()
        leaves_mesh.radius = 1.0
        leaves_mesh.height = 2.0
        leaves.mesh = leaves_mesh
        leaves.position.y = 2.5

        var leaves_mat = StandardMaterial3D.new()
        leaves_mat.albedo_color = Color(0.08, 0.38, 0.12)
        leaves.material_override = leaves_mat
        tree.add_child(leaves)

    # Трамплины
    for i in range(2):
        var ramp = MeshInstance3D.new()
        var ramp_mesh = BoxMesh.new()
        ramp_mesh.size = Vector3(2.5, 0.35, 3.0)
        ramp.mesh = ramp_mesh
        ramp.position = Vector3(-5 + i * 10, 0.5, -3)
        ramp.rotation_degrees.x = -12

        var ramp_mat = StandardMaterial3D.new()
        ramp_mat.albedo_color = Color(0.15, 0.2, 0.3)
        ramp.material_override = ramp_mat
        add_child(ramp)

    # Освещение
    var glow = OmniLight3D.new()
    glow.position = Vector3(0, 8, 0)
    glow.light_energy = 1.2
    glow.omni_range = 25
    add_child(glow)
