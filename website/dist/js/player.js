const context = new AudioContext()

class DemoPlayer {
  constructor(slideshow, context, element) {
    this.active = false
    this.slideshow = slideshow
    this.context = context
    this.element = element
    this.sourceNode = new MediaElementAudioSourceNode(this.context, {mediaElement: element})
    this.analyzer = context.createAnalyser()
    console.log(this.analyzer.frequencyBinCount)
    this.sourceNode.connect(this.analyzer)
    this.sourceNode.connect(this.context.destination)
    this.playerType = element.getAttribute('data-player')
    this.insertUI()
    this.slideshow.on('hideSlide', () => { this.active = false})
  }
  insertUI() {
    const wrapper = document.createElement('div')
    wrapper.className = `player player-${this.playerType}`


    const playButton = document.createElement('button')
    const buttonText = document.createTextNode("Play ▶")
    playButton.appendChild(buttonText)
    this.element.parentNode.insertBefore(wrapper, this.element.nextSibling)
    playButton.addEventListener('click', (e) => this.element.play())
    this.element.addEventListener('play', this.play.bind(this))
    if (this.playerType === 'scope') {
      this.scope = document.createElement('canvas')
      this.scope.className = "scope"
      this.scope.width = 200
      this.scope.height = 200
      wrapper.appendChild(this.scope)
      this.scopeContext = this.scope.getContext('2d')
      this.updateScope = this.updateScope.bind(this)
    }
    if (this.playerType === 'fft') {
      this.scope = document.createElement('canvas')
      this.scope.className = "scope"
      this.scope.width = 600
      this.scope.height = 200
      wrapper.appendChild(this.scope)
      this.scopeContext = this.scope.getContext('2d')
      this.updateFFT = this.updateFFT.bind(this)
    }
    wrapper.appendChild(playButton)
  }
  updateScope() {
    const dataArray = new Float32Array(this.analyzer.fftSize)
    this.analyzer.getFloatTimeDomainData(dataArray)
    this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
    this.scopeContext.strokeStyle = "#0f0"
    this.scopeContext.lineWidth = 4
    this.scopeContext.beginPath()
    this.scopeContext.moveTo(0, 100)
    dataArray.forEach(function(v, i) {
      const x = i / this.analyzer.fftSize * this.scope.width
      const halfHeight = this.scope.height / 2
      const y = v * halfHeight + halfHeight
      this.scopeContext.lineTo(x,y)
    }, this)
    this.scopeContext.stroke()
    if (this.active) {
      requestAnimationFrame(this.updateScope)
    }
  }
  updateFFT() {
    const dataArray = new Float32Array(this.analyzer.frequencyBinCount)
    this.analyzer.getFloatFrequencyData(dataArray)
    // console.log(dataArray)
    this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
    this.scopeContext.strokeStyle = "#0f0"
    this.scopeContext.lineWidth = 4
    this.scopeContext.beginPath()
    dataArray.forEach(function(v, i) {
      const x = i / this.analyzer.frequencyBinCount * this.scope.width
      const halfHeight = this.scope.height / 2
      const y = this.scope.height - (v + 140) * 2
      if (i == 0) { this.scopeContext.moveTo(x, y) }
      this.scopeContext.lineTo(x,y)
    }, this)
    this.scopeContext.stroke()
    if (this.active) {
      requestAnimationFrame(this.updateFFT)
    }
  }
  play() {
    this.context.resume()
    if (!this.active) {
      this.active = true
      if (this.playerType === 'scope') {
        this.updateScope()
      }
      if (this.playerType === 'fft') {
        this.updateFFT()
      }
    }
  }

}

function initPlayer() {
  document.querySelectorAll('audio[data-player]').forEach(function(element) {
    let sl = null
    if (typeof slideshow !== 'undefined') {
      sl = slideshow
    }
    new DemoPlayer(sl, context, element)
  })
}
