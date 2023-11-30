extends Polygon2D

# Create a sprite, convert to polygon2d, n then attach this script

enum SkewDirection { RIGHT, DOWN, LEFT, UP }
@export var direction : SkewDirection = SkewDirection.UP

@onready var viewport_rect_size : Vector2 = get_viewport_rect().size
var canvas_rel : Vector2
var canvas_pos : Vector2
var texture_rel : PackedVector2Array
var texture_size : Vector2
var texture_dir : Vector2
var polygon_idx : Vector2i
var top_scale : float

func get_polygon_idx( vec_dir : Vector2i ) -> Vector2i:
    var rad : float = atan2( vec_dir.y, vec_dir.x )
    var idx : int = int( remap( rad, -PI * 0.5, PI, 0, 3 ) )
    return Vector2i(
        wrapi( idx, 0, 4 ),
        wrapi( idx + 1, 0, 4 )
    )

func _ready() -> void:

    top_scale = Global.top_scale
    texture_size = texture.get_size()

    match direction:
        SkewDirection.UP:   # 0,    0, -1
            texture_dir = Vector2.UP * texture_size
            texture_rel = [
                ( texture_size * 0.5 ) * Vector2( 1, 1 ),
                ( texture_size * 0.5 ) * Vector2( -1, 1 ),
            ]

        SkewDirection.RIGHT:   # 1,    1, 0
            texture_dir = Vector2.RIGHT * texture_size
            texture_rel = [
                ( texture_size * 0.5 ) * Vector2( -1, 1 ),
                ( texture_size * -0.5 ) * Vector2( 1, 1 ),
            ]

        SkewDirection.DOWN:   # 2,    0, -1
            texture_dir = Vector2.DOWN * texture_size
            texture_rel = [
                ( texture_size * -0.5 ) * Vector2( 1, 1 ),
                ( texture_size * 0.5 ) * Vector2( 1, -1 ),
            ]

        SkewDirection.LEFT:   # 3,    -1, 0
            texture_dir = Vector2.LEFT * texture_size
            texture_rel = [
                ( texture_size * 0.5 ) * Vector2( 1, -1 ),
                ( texture_size * 0.5 ) * Vector2( 1, 1 ),
            ]

    polygon_idx = get_polygon_idx( texture_dir.sign() )

func _process( _delta ) -> void:
    if visible:
        canvas_pos = ( ( \
            get_global_transform_with_canvas().origin * 2 ) /\
            viewport_rect_size ) - Vector2.ONE

        canvas_rel =\
            texture_dir +\
            ( canvas_pos * texture_size ) +\
            ( canvas_pos * top_scale )

        polygon[ polygon_idx.x ] = canvas_rel + ( position + texture_rel[ 0 ] )
        polygon[ polygon_idx.y ] = canvas_rel + ( position + texture_rel[ 1 ] )
