#=require fabric
jQuery ->
  @z = new fabric.StaticCanvas 'blackbird_fly', {centeredRotation: true, centeredScaling: true}
  @cicrle = new fabric.Circle {radius: 200, left: 0, top: 0, opacity: 0}
  @square = new fabric.Rect {width: 400, height: 400, left: 0, top: 0, opacity: 0}
  @baseshapes = [@square, @cicrle]
  @transforms = JSON.parse $("#transforms").val()

  @z.add @cicrle
  @z.add @square
  @rec=0
  @images = []
  max_rec= ->
    parseInt $('#max_rec').val()

  create_image= (img, cb)=>
     new Promise (fulfil, reject) =>
      fabric.Image.fromURL img, (oimg)=>
        fulfil(oimg)

  heraksimo= =>
    setTimeout heraks, 500
  heraks= =>
    if rec == 0
      shape = @baseshapes[ parseInt  $('#base_shape').val() ]
      shape.set {opacity: 1}
      @z.renderAll()
    rec+=1
    img = $('#blackbird_fly')[0].toDataURL("image/png")
    @cicrle.set {'opacity': 0}
    @square.set {'opacity': 0}
    simgs=[]
    for rect in @transforms
      simgs.push img
    Promise.all(simgs.map create_image).then (fabric_images)=>
      for image in @images
        image.remove()
      @images=[]
      for i in [0...fabric_images.length]
        rect = @transforms[i]
        oimg = fabric_images[i]
        oimg.set rect
        @z.add oimg
        @images.push oimg
        @z.renderAll()
      if @rec < max_rec()
        heraksimo()
      else
        for image in @images
          image.remove()
        @images=[]
        @rec=0
        @z.renderAll()
        heraksimo()
        
  heraksimo()
  
