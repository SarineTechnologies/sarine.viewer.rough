###!
sarine.viewer.rough - v1.0.0 -  Monday, January 1st, 2018, 2:27:23 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###

class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
    console.log("")
    @first_init_defer = $.Deferred()
    @full_init_defer = $.Deferred()
    {@src, @element,@autoPlay,@callbackPic} = options
    @id = @element[0].id;
    @element = @convertElement()
    Object.getOwnPropertyNames(Viewer.prototype).forEach((k)-> 
      if @[k].name == "Error" 
          console.error @id, k, "Must be implement" , @
    ,
      @)
    @element.data "class", @
    @element.on "play", (e)-> $(e.target).data("class").play.apply($(e.target).data("class"),[true])
    @element.on "stop", (e)-> $(e.target).data("class").stop.apply($(e.target).data("class"),[true])
    @element.on "cancel", (e)-> $(e.target).data("class").cancel().apply($(e.target).data("class"),[true])
  error = () ->
    console.error(@id,"must be implement" )
  first_init: Error
  full_init: Error
  play: Error
  stop: Error
  convertElement : Error
  cancel : ()-> rm.cancel(@)
  loadImage : (src)-> rm.loadImage.apply(@,[src])
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 
    
@Viewer = Viewer 

class SarineRoughDiamond extends Viewer
	
	pluginDimention = undefined

	constructor: (options) -> 			
		super(options)	
		{@ImagesPath, @ImageName, @NumberOfImages, @ImageExtention, @ImagePrefix} = options	
		@isAvailble = true
		@resourcesPrefix = options.baseUrl + "atomic/v1/assets/"	
		@resources = [
	      {element:'script',src:'threesixty.min.js'},
	      {element:'link',src:'threesixty.css'}
	    ]	

	convertElement : () ->	
		pluginDimention = if @element.parent().height() != 0 then @element.parent().height() else 300
		margin = (pluginDimention / 2 - 15) #we reduce 15px cause the default loader height is 30px
		@element.append '<div id="sarine-rough" class="threesixty ringImg"><div class="spinner" style="margin-top:' + margin + 'px;"><span>0%</span></div><ol class="threesixty_images"></ol></div></div>'	 	

	preloadAssets: (callback)=>

	    loaded = 0
	    totalScripts = @resources.map (elm)-> elm.element =='script'
	    triggerCallback = (callback) ->
	      loaded++
	      if(loaded == totalScripts.length-1 && callback!=undefined )
	        setTimeout( ()=> 
	          callback() 
	        ,500) 

	    element
	    for resource in @resources
	      element = document.createElement(resource.element)
	      if(resource.element == 'script')
	        $(document.body).append(element)
	        element.onload = element.onreadystatechange = ()-> triggerCallback(callback)
	        element.src = @resourcesPrefix + resource.src + cacheVersion
	        element.type= "text/javascript"

	      else
	        element.href = @resourcesPrefix + resource.src + cacheVersion
	        element.rel= "stylesheet"
	        element.type= "text/css"
	        $(document.head).prepend(element) 
	        
	first_init : ()->
		defer = $.Deferred() 
		_t = @
		@preloadAssets ()->
			src = configuration.configUrl + _t.ImagesPath + _t.ImageName + _t.ImageExtention
			_t.loadImage(src).then((img)->	
				if img.src.indexOf('data:image') == -1 && img.src.indexOf('no_stone') == -1			
					defer.resolve(_t)
				else
					_t.isAvailble = false
					_t.element.empty()
					@canvas = $("<canvas>")		
					@canvas[0].width = img.width
					@canvas[0].height = img.height
					@ctx = @canvas[0].getContext('2d')
					@ctx.drawImage(img, 0, 0, img.width, img.height)
					@canvas.attr {'class' : 'no_stone'}					
					_t.element.append(@canvas)
					defer.resolve(_t)										
				) 
		defer

	full_init : ()-> 
		defer = $.Deferred()
		if @isAvailble
			$('.ringImg').ThreeSixty({
				totalFrames: @NumberOfImages, # Total no. of image you have for 360 slider
				endFrame: @NumberOfImages, # end frame for the auto spin animation
				currentFrame: 1, # This the start frame for auto spin
				imgList: '.threesixty_images', # selector for image list
				progress: '.spinner', # selector to show the loading progress
				imagePath: configuration.configUrl + '/images/', # path of the image assets
				filePrefix: @ImagePrefix, # file prefix if any
				ext: @ImageExtention, # extention for the assets
				height: pluginDimention,
				width: pluginDimention,
				navigation: false,
				responsive: true
			}); 
					
		defer.resolve(@)
		defer
		
	play : () -> return		
	stop : () -> return

@SarineRoughDiamond = SarineRoughDiamond
		


