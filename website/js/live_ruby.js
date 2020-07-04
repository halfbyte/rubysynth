  function drawInCanvas(selector, data) {
    const canvas = document.querySelector(selector)
    const ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    const perStep = canvas.width / data.length
    const height = canvas.height
    ctx.strokeStyle = "#000"
    ctx.strokeWidth = 2
    ctx.beginPath()
    ctx.moveTo(0, height / 2)
    data.forEach((d, x) => ctx.lineTo(perStep * x, ((d + 1) / 2 * height)))
    ctx.stroke()
  }

  document.getElementById('run-button').onclick = function(e) {
    e.preventDefault()
    const code = document.getElementById('code').value
    console.log(code)
    const evaluated = Opal.eval(code)
    
    const context = new AudioContext()
    const buffer = context.createBuffer(1, evaluated.length, 44100)
    const data = buffer.getChannelData(0)
    evaluated.forEach((w, i) => data[i] = w)

    const samplePlayer = context.createBufferSource()
    samplePlayer.connect(context.destination)
    samplePlayer.buffer = buffer
    samplePlayer.start()
    drawInCanvas('#canvas', evaluated)

  }

