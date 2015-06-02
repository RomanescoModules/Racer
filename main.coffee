lock = g.items["556d70281f1e0401feabc02d"]

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
		nextCarPosition = car.position.add(car.direction.multiply(car.speed))
		if not lock.track.contains(nextCarPosition)
			lock.bumpCar(car)
	
	checkpoint = lock.checkpoints[lock.currentCheckpoint]
	if checkpoint.contains(car.position)
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
		car.nBumps = 0
	return

lock.bumpCar = (car)->
	nearestPoint = null
	nearestPath = null
	minDistance = null
	for path in lock.track.paths
		point = path.getNearestPoint(nextCarPosition)
		distance = point.getDistance(nextCarPosition, true)
		if not minDistance or distance < minDistance
			minDistance = distance
			nearestPoint = point
			nearestPath = path
	tangent = nearestPath.getTangentAt(nearestPath.getOffsetOf(nearestPoint))
	theta = tangent.getAngle(car.direction)
	if theta>90
		tangent = tangent.multiply(-1)
		theta = 180 - theta
	car.direction = tangent
	car.speed *= (90 - theta) / 90
	car.nBumps ?= 0
	car.nBumps++
	if car.nBumps>5
		lock.gameStarted = false
		g.romanesco_alert "Car exploded!", "warning"
	return

lock.finishGame = ()->
	time = (Date.now() - lock.startTime)/1000
	g.romanesco_alert "You won ! Your time is: " + time.toFixed(2) + " seconds.", "success"
	lock.currentCheckpoint = -1
	lock.gameStarted = false
	return

g.registerAnimation(lock)
