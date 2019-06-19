const context = new AudioContext()

class DemoPlayer {
  constructor(slideshow, context, element) {
    this.active = false
    this.slideshow = slideshow
    this.context = context
    this.element = element
    this.sourceNode = new MediaElementAudioSourceNode(this.context, {mediaElement: element})
    this.analyzer = context.createAnalyser()
    this.analyzer.fftSize = 4096
    console.log(this.analyzer.frequencyBinCount)
    this.sourceNode.connect(this.analyzer)
    this.sourceNode.connect(this.context.destination)
    const player = element.getAttribute('data-player')
    const [playerType, playerVariant] = player.split('-')
    this.playerType = playerType
    this.playerVariant = playerVariant
    this.slideParent = this.element.closest('.remark-slide-content')
    this.insertUI()
    if (this.slideshow != null) {
      this.slideshow.on('hideSlide', () => { this.active = false})
    }
    this.element.addEventListener('play', this.play.bind(this))
    this.element.addEventListener('ended', this.ended.bind(this))
  }
  insertUI() {
    const wrapper = document.createElement('div')
    wrapper.className = `player player-${this.playerType}`
    const playButton = document.createElement('button')
    const buttonText = document.createTextNode("Play ▶")
    playButton.appendChild(buttonText)
    this.element.parentNode.insertBefore(wrapper, this.element.nextSibling)
    playButton.addEventListener('click', (e) => this.element.play())

    this.scope = document.createElement('canvas')
    this.scopeContext = this.scope.getContext('2d')
    this.scope.width = 2048
    this.scope.height = 1152

    if (this.playerType !== 'simple') {
      if (this.playerVariant === 'full' && this.slideParent != null) {
        this.scope.className = "scope-full"
        this.slideParent.appendChild(this.scope)
      } else {
        this.scope.className = "scope"
        wrapper.appendChild(this.scope)
      }
    }

    if (this.playerType === 'scope') {
      this.updateScope = this.updateScope.bind(this)
    }
    if (this.playerType === 'fft') {
      this.updateFFT = this.updateFFT.bind(this)
    }
    wrapper.appendChild(playButton)
  }
  updateScope() {
    const dataArray = new Float32Array(this.analyzer.fftSize)
    const halfHeight = this.scope.height / 2
    this.analyzer.getFloatTimeDomainData(dataArray)
    this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
    if (this.playerVariant === 'full') {
      this.scopeContext.strokeStyle = "rgba(0,128,0,0.5)"
    } else {
      this.scopeContext.strokeStyle = "#0f0"
    }
    this.scopeContext.lineWidth = 4
    this.scopeContext.beginPath()
    this.scopeContext.moveTo(0, halfHeight)
    dataArray.forEach(function(v, i) {
      const x = i / this.analyzer.fftSize * this.scope.width
      const y = v * halfHeight + halfHeight
      this.scopeContext.lineTo(x,y)
    }, this)
    this.scopeContext.stroke()
    if (this.active) {
      requestAnimationFrame(this.updateScope)
    } else {
      this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
    }
  }
  updateFFT() {
    const dataArray = new Uint8Array(this.analyzer.frequencyBinCount)
    this.analyzer.getByteFrequencyData(dataArray)
    // console.log(dataArray)
    this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
    if (this.playerVariant === 'full') {
      this.scopeContext.strokeStyle = "rgba(0,128,0,0.5)"
    } else {
      this.scopeContext.strokeStyle = "#0f0"
    }
    this.scopeContext.lineWidth = 4
    this.scopeContext.beginPath()
    dataArray.forEach(function(v, i) {
      const x = i / this.analyzer.frequencyBinCount * this.scope.width
      const halfHeight = this.scope.height / 2
      const y = this.scope.height - (this.scope.height * (v / 255))
      if (i == 0) { this.scopeContext.moveTo(x, y) }
      this.scopeContext.lineTo(x,y)
    }, this)
    this.scopeContext.stroke()
    if (this.active) {
      requestAnimationFrame(this.updateFFT)
    } else {
      this.scopeContext.clearRect(0, 0, this.scope.width, this.scope.height)
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
  ended() {
    this.active = false
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
