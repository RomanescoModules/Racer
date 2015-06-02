lock = g.currentLock

lock.currentCheckpoint = 0
lock.checkpoints = []
lock.gameStarted = false

track = new CompoundPath()
track.fillColor = 'red'
lock.track = track

for item in lock.children()

	switch item.data.type
		when 'track'
			trackPath = item.controlPath.clone()
			trackPath.visible = true
			trackPath.closed = true
			trackPath.fillColor = 'red'
			track.addChild(trackPath)
		when 'checkpoint'
			lock.checkpoints.push(item)
			item.data.checkpointNumber ?= lock.checkpoints.length

lock.onFrame = (event)->
	car = g.tools['Car'].car
	if not car?
		lock.gameStarted = false
		return

	if lock.gameStarted
		if not lock.track.contains(car.position)
			lock.onBounce(car)

	checkpoint = lock.checkpoints[lock.currentCheckpoint]
	if checkpoint.contains(car.position)
		lock.passCheckpoint()
	return

lock.passCheckpoint = ()->
	switch lock.currentCheckpoint
		when 0
			lock.startTime = Date.now()
			lock.gameStarted = true
			g.romanesco_alert "Game started, go go go!", "success"
		when lock.checkpoints.length-1
			lock.finishGame()
		else
			g.romanesco_alert "Checkpoint " + lock.currentCheckpoint + " passed!", "success"
	lock.currentCheckpoint++
	return

lock.onBounce = (car)->
	position = car.position # car.position.add(car.direction.multiply(car.speed))
	nearestPoint = null
	nearestPath = null
	minDistance = null
	for path in lock.track.children
		point = path.getNearestPoint(position)
		distance = point.getDistance(position, true)
		if not minDistance or distance < minDistance
			nearestPoint = point
			nearestPath = path
			minDistance = distance
	tangent = nearestPath.getTangentAt(path.getOffsetOf(nearestPoint))
	theta = tangent.getAngle(car.direction)
	if theta > 90
		tangent = tangent.multiply(-1)
		theta = 180 - theta
	car.speed = (90 - theta) / 90
	car.direction = tangent
	car.position = nearestPoint
	car.nBumps ?= 0
	car.nBumps++
	if car.nBumps>5
		lock.gameStarted = false
	return

lock.finishGame = ()->
	time = (Date.now() - lock.startTime)/1000
	g.romanesco_alert "You won ! Your time is: " + time.toFixed(2) + " seconds.", "success"
	lock.currentCheckpoint = -1
	return

g.registerAnimation(lock)
