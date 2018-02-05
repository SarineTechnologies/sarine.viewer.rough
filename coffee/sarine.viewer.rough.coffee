class SarineRoughDiamond extends Viewer
	
	constructor: (options) -> 			
		super(options)
		@isAvailble = true
		@resourcesPrefix = options.baseUrl + "atomic/v1/assets/"
		@atomConfig = configuration.experiences.filter((exp)-> exp.atom == "roughDiamond")[0] 	
		@resources = [
	      {element:'script',src:'threesixty.min.js'},
	      {element:'link',src:'threesixty.css'}
	    ]

		css = '.sarine-slider {width: ' + @atomConfig.ImageSize.width + 'px; height: ' + @atomConfig.ImageSize.height + 'px}'
		css += '.spinner {margin-top: 40% !important}'
		head = document.head || document.getElementsByTagName('head')[0]
		style = document.createElement('style')
		style.type = 'text/css'
		if (style.styleSheet)
			style.styleSheet.cssText = css
		else
			style.appendChild(document.createTextNode(css))		
		head.appendChild(style)

		@pluginDimention = if @atomConfig.ImageSize && @atomConfig.ImageSize.height then @atomConfig.ImageSize.height else 300

		@domain = window.coreDomain # window.stones[0].viewersBaseUrl.replace('content/viewers/', '')
		@path = "demo/r2p/" + window.stones[0].friendlyName + "/interactive"	

	convertElement : () ->	
		@element.append '<div class="threesixty slider360 sarine-slider"><div class="spinner"></div><ol class="threesixty_images"></ol></div></div>'

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
			@firstImageName = _t.atomConfig.ImagePattern.replace("*","1") 
			src = _t.domain + _t.path + "/" + @firstImageName + cacheVersion
			
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
			@slider360 = @element.find('.slider360')
			
			@imagePath = @domain + @path + "/"
			
			@filePrefix = @atomConfig.ImagePattern.replace(/\*.[^/.]+$/,'')
			@fileExt = ".#{@atomConfig.ImagePattern.split('.').pop()}"
			@slider360.ThreeSixty({
				totalFrames: @atomConfig.NumberOfImages, # Total no. of image you have for 360 slider
				endFrame: @atomConfig.NumberOfImages, # end frame for the auto spin animation
				currentFrame: 1, # This the start frame for auto spin
				imgList: '.threesixty_images', # selector for image list
				progress: '.spinner', # selector to show the loading progress
				imagePath: @imagePath, # path of the image assets
				filePrefix: @filePrefix, # file prefix if any 
				ext: @fileExt + cacheVersion, # extention for the assets
				height: @pluginDimention, 
				width: @pluginDimention,
				navigation: false,
				responsive: false,
				onReady: () ->
					defer.resolve(@)									
			}); 
		defer	
		
	play : () -> return		
	stop : () -> return

@SarineRoughDiamond = SarineRoughDiamond