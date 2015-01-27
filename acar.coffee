#flags
_DEBUG_ = true

#globals
_game_ = {}
_nav_ = {}
_graphics_ = {}

_car_ = {}
_w_ = 0
_h_ = 0
_level_ = {}
_sprite_collector_ = {}
_speed_ = _default_speed_ = 30
_game_debug_ = false

gd = () -> 
  if _game_debug_ is true then return true
  return false 


d = (m) -> console.log(m) if _DEBUG_

rand = (min = 0, max = 255) ->
  Math.floor(Math.random() * (max - min)) + min


_pos_car_body_ = []
_pos_back_wheel_ = []
_pos_front_wheel_ = []

preDrawACar = (canvas) ->
  ctx = canvas.getContext("2d")
  ctx.strokeStyle = '#D3D3D3'
  ctx.fillStyle = '#FFFFFF'
  ctx.lineWidth = 1
  ctx.beginPath()
  ctx.moveTo(50, 200)
  ctx.lineTo(200, 200)
  ctx.lineTo(200, 70)
  ctx.lineTo(400, 70)
  ctx.lineTo(400, 200)
  ctx.lineTo(550, 200)
  ctx.lineTo(550, 350)
  ctx.lineTo(550, 350)
  ctx.lineTo(525, 350)
  ctx.arc(440, 350, 80, 0 * Math.PI, 1 * Math.PI, true)
  ctx.lineTo(240, 350)
  ctx.arc(160, 350, 80, 0 * Math.PI, 1 * Math.PI, true)
  ctx.lineTo(50, 350)
  ctx.closePath()
  ctx.stroke()

  ctx.beginPath()
  ctx.rect(25,25,550,400)
  _pos_car_body_ = [25,25,550,400]
  ctx.setLineDash([2,3])
  ctx.stroke()
  ctx.closePath()

  drawWheel = (x,y,r) ->
    ctx.beginPath()
    ctx.arc(x, y, r, 0 * Math.PI, 2 * Math.PI, true)
    ctx.stroke()
    ctx.closePath()

    ctx.beginPath()
    #ctx.strokeStyle = 'red'
    ctx.setLineDash([2,3])
    dist = 20
    ctx.rect(x2=(x-(r+dist)), y2=(y-(r+dist)), w2=((r+dist)*2), h2=((r+dist)*2))
    ctx.stroke()
    return [x2,y2,w2,h2]

  _pos_back_wheel_ = drawWheel(750,220,140)
  d(_pos_back_wheel_)
  _pos_front_wheel_ = drawWheel(1100,220,140)
  d(_pos_front_wheel_)


drawWithMouse = (canvas) ->
  ctx = canvas.getContext("2d")
  ctx.strokeStyle = '#000000'
  ctx.lineWidth = 25
  
  clicked = 0

  start = (e) ->
    clicked = 1
    ctx.beginPath()
    x = e.pageX
    y = e.pageY
    ctx.moveTo(x,y)
  
  move = (e) ->
    if clicked
      x = e.pageX
      y = e.pageY
      ctx.lineTo(x,y)
      ctx.stroke()

  stop = (e) ->
    clicked = 0

  canvas.addEventListener("mousedown", start, false)
  canvas.addEventListener("mousemove", move, false)
  canvas.addEventListener("mouseup", stop, false)

drawCar = (cb) ->
  #create a canvas
  blueprint_canvas = document.createElement('canvas')
  draw_canvas = document.createElement('canvas')
  draw_canvas.width = blueprint_canvas.width = _w_
  draw_canvas.height =  blueprint_canvas.height =  _h_
  draw_canvas.id = "draw_canvas"
  blueprint_canvas.id = "blueprint_canvas"
  preDrawACar(blueprint_canvas)
  drawWithMouse(draw_canvas)
  blueprint_canvas.setAttribute('style', 'position:absolute;top:0px;left:0px;z-index: +1;')
  draw_canvas.setAttribute('style', 'position:absolute;top:0px;left:0px;z-index: +2;')
  window.document.body.appendChild(blueprint_canvas)
  window.document.body.appendChild(draw_canvas)
  button = document.createElement('button')
  button.innerHTML = 'Draw a car and two wheels and then click this button!'
  button.setAttribute('style', 'position: absolute; top: 5; left: 10;z-index: +3;')
  window.document.body.appendChild(button)
  
  button.addEventListener('click', () -> 
    draw_canvas.setAttribute('style','display:none;')
    blueprint_canvas.setAttribute('style','display:none;')
    button.setAttribute('style','display:none;')
    cutAndSet = (resize_factor, pos_array, set_target) ->
      [x,y,w,h] = pos_array
      c2 = document.createElement('canvas')
      c2.width = w/resize_factor
      c2.heigth = h/resize_factor
      c2ctx = c2.getContext("2d")
      #[x,y,w,h] = _pos_car_body_
      c2ctx.drawImage(draw_canvas, x,y,w,h,0,0,c2.width,c2.heigth)
      #c2ctx.drawImage(draw_canvas,0,0)
      _sprite_collector_[set_target] = new Image()
      _sprite_collector_[set_target].width = c2.width
      _sprite_collector_[set_target].height = c2.heigth
      _sprite_collector_[set_target].src = c2.toDataURL()

    cutAndSet(5, _pos_car_body_, "car_body")
    cutAndSet(8, _pos_front_wheel_, "front_wheel")
    cutAndSet(8, _pos_back_wheel_, "back_wheel")

    #c3 = 

    #_front_wheel_image_ = new Image()    
    cb()
  )


  #draw premature care on there
  #add drawing 
  #attach canvas to DOM
  #let them draw a car
  #let them click on a section of the canvas
  #extract the main body of the car and the wheels
  #save it globally
  #cb()

init = () ->
  d('init')
  _w_ = window.innerWidth
  _h_ = window.innerHeight; 
  drawCar( () ->
    _game_ = new Phaser.Game(_w_, _h_, Phaser.AUTO, '', {
      preload: preload
      create: create
      update: update
      render: render
      })
    )

preload = () ->
  d('preload')
  #dataURI =  'data:image/jpeg;base64,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';

#  data = new Image()
#  data.src = _car_body_image_.src;
  #_game_.load.image('test', 'sprite.jpg')
  _game_.cache.addImage('car-body', _sprite_collector_.car_body.src, _sprite_collector_.car_body)
  _game_.cache.addImage('back-wheel', _sprite_collector_.back_wheel.src, _sprite_collector_.back_wheel)
  _game_.cache.addImage('front-wheel', _sprite_collector_.front_wheel.src, _sprite_collector_.front_wheel)

create = () ->
  d('create')
  _graphics_ = _game_.add.graphics(0,0)
  _game_.world.setBounds(0, 0, _w_*1000, _h_)
  _game_.physics.startSystem(Phaser.Physics.P2JS)
  _game_.physics.p2.gravity.y = 300
  _game_.physics.p2.restitution = 0.4
  _game_.stage.backgroundColor = '#ffffff'
  _game_.physics.p2.friction = 5


  _nav_ = _game_.input.keyboard.createCursorKeys()
  _nav_.d = _game_.input.keyboard.addKey(Phaser.Keyboard.D)
  _nav_.t = _game_.input.keyboard.addKey(Phaser.Keyboard.T)

  _car_ = makeCar(_game_, _nav_)
  _level_ = makeLevel(_game_, _nav_, _car_)
  _game_.camera.follow(_car_.main)

update = () ->
  #d('update')
  #_game_.physics.p2.walls.bottom.velocity[0] = _car_.back_wheel.body.angularVelocity+(_car_.body.position.x-(_w_/2-_w_/4+100))/1000

  #for j, i in _level_.jumps
  #  j.body.velocity.x = _car_.back_wheel.body.angularVelocity*-10

  if _nav_.right.isDown
    d('->')
    _car_.back_wheel.body.angularVelocity = _speed_
    _car_.front_wheel.body.angularVelocity = _speed_
  
  if _nav_.left.isDown
    d('<-')
    _car_.back_wheel.body.angularVelocity = _speed_ * -1
    _car_.front_wheel.body.angularVelocity = _speed_ * -1

  if _nav_.up.isDown
    d('^')
    _car_.main.body.angle = _car_.main.body.angle - 1
    _car_.main.body.angularVelocity = 0.0001

  if _nav_.down.isDown
    d('v')
    _car_.main.body.angle = _car_.main.body.angle + 1
    _car_.main.body.angularVelocity = 0.0001

  if _nav_.d.isDown
    d('game debug')
    _game_debug_ = !gd()
    _car_.main.body.debug = gd()
    _car_.front_wheel.body.debug = gd()
    _car_.back_wheel.body.debug = gd()

  if _nav_.t.isDown
    _speed_ = _default_speed_ * 2.8
  else
    _speed_ = _default_speed_

makeCar = (g,n) ->
  car_main  = g.add.sprite(100, 100, 'car-body')
  front_wheel = g.add.sprite(140, 130, 'front-wheel')
  back_wheel = g.add.sprite(60, 130, 'back-wheel')
  cg_car = g.physics.p2.createCollisionGroup()
  g.physics.p2.updateBoundsCollisionGroup()
  g.physics.p2.enable([front_wheel, back_wheel, car_main])



  car_main.body.setRectangle(105,75);
  car_main.body.debug = gd()
  car_main.body.mass = 1;
  car_main.body.setCollisionGroup(cg_car);

  front_wheel.body.setCircle(20);
  front_wheel.body.debug = gd()
  front_wheel.body.mass = 1;
  front_wheel.body.setCollisionGroup(cg_car);

  back_wheel.body.setCircle(20);
  back_wheel.body.debug = gd()
  back_wheel.body.mass = 1;
  back_wheel.body.setCollisionGroup(cg_car);

  front_spring = g.physics.p2.createSpring(car_main,front_wheel, 70, 150, 50,null,null,[30,0],null)
  back_spring = g.physics.p2.createSpring(car_main,back_wheel, 70, 150, 50,null,null,[-30,0],null)

  front_constraint = g.physics.p2.createPrismaticConstraint(car_main,front_wheel, false,[30,0],[0,0],[0,1])
  front_constraint.lowerLimitEnabled = front_constraint.upperLimitEnabled = true
  front_constraint.upperLimit = -1
  front_constraint.lowerLimit = -8

  back_constraint = g.physics.p2.createPrismaticConstraint(car_main,back_wheel, false,[-30,0],[0,0],[0,1])
  back_constraint.lowerLimitEnabled = back_constraint.upperLimitEnabled = true
  back_constraint.upperLimit = -1
  back_constraint.lowerLimit = -8

  return {
    main: car_main
    front_wheel: front_wheel
    back_wheel: back_wheel
    front_spring: front_spring
    back_spring: back_spring
    cg_car: cg_car
  }

makeLevel = (g,n,c) ->
  text = "←/→ = left/right \n ↑/↓ = wheelie/anti-wheelie \n t = turbo "
  style = { font: "28px Courier", fill: "#000000", align: "center" }
  t = _game_.add.text(80, 80, text, style)
  #alert(text)

  ground = g.add.group()
  jumps = []
  for i in [0 ... 29]
    jumps.push(addJump(ground, (600*(i+1))+rand(0,800), _h_, rand(50,_w_*0.5), rand(10,_h_*0.6), g, n, c))

  return {
    ground: ground
    jumps: jumps
  }

_jump_counter_ = 0
addJump = (ground, x = 500, y = _h_, width=700, height = 50, g = _game_, n = _nav_, c = _car_, counter = _jump_counter_++) ->

  _graphics_.beginFill(0xffffff);
  _graphics_.lineStyle(5, 0x000000, 1)

  jump_polygon = [[x,y], [x+width, y-height], [x+(width*2), y]]
  _graphics_.moveTo(x,y)
  _graphics_.lineTo(x+width, y-height)
  _graphics_.lineTo(x+(width*2), y)
  _graphics_.endFill()

  cg_level = g.physics.p2.createCollisionGroup()
  g.physics.p2.updateBoundsCollisionGroup()
  jump = ground.create(0,0)
  jump.anchor.setTo(0.5, 0.5)
  g.physics.p2.enable(jump, true, true)
  
  jump.body.mass = 10
  jump.body.debug = gd()
  jump.body.addPolygon({}, jump_polygon)
  jump.body.kinematic = true
  jump.body.setCollisionGroup(cg_level)
  jump.body.fixedRotation = true
  jump.body.data.gravityScale = 0
  jump.body.collides(c.cg_car)
  jump.body.collideWorldBounds = false

  c.front_wheel.body.collides(cg_level)
  c.back_wheel.body.collides(cg_level)
  c.main.body.collides(cg_level)

  return jump

render = () -> 
  #
  if gd()
    _game_.debug.cameraInfo(_game_.camera, 32, 32, '#000000');
  else
    _game_.debug.cameraInfo(_game_.camera, -300, -300, '#000000');

window.document.onload = init()