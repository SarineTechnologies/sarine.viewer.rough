class SarineRoughDiamond extends Viewer

	constructor: (options) -> 			
		super(options)
		@isAvailble = true
		@assetsPrefix = options.baseUrl + "atomic/v1/assets/"
		@atomConfig = configuration.experiences.filter((exp)-> exp.atom == "roughDiamond")[0]
		@assets = [
			{element:'script',src: @assetsPrefix + 'sarine.plugin.imgplayer.min.js'},
			{element:'link',src: @assetsPrefix + 'sarine.plugin.imgplayer.min.css'}
		]
		@domain = window.stones[0].viewers.roughViewer
		@speed = @atomConfig && @atomConfig.speed || 10
		@autoPlay = @atomConfig && @atomConfig.autoPlay

	convertElement : () ->	
		@element
	        
	first_init : ()->
		defer = $.Deferred() 
		_t = @
		@firstImageName = _t.atomConfig.ImagePattern.replace("*","1")

		src = _t.domain + @firstImageName + cacheVersion
		
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
			@roughDiamond = @element			
			_t = @;
			_t.loadAssets(@assets,() ->
				imageNameLocal = _t.atomConfig.ImagePattern.replace('*', '{num}')
				_t.roughDiamond.imgplay({
					startImage: 1,
					totalImages: _t.atomConfig.NumberOfImages,
					imageName: imageNameLocal,                            
					urlDir:  _t.domain + imageNameLocal,
					height: _t.atomConfig.width || 300,
					width: _t.atomConfig.height || 300,
					autoPlay: _t.autoPlay ,
					rate: _t.speed
				})
				_t.roughDiamond.on("play", (event, plugin) ->
				)
				_t.roughDiamond.on("pause", (event, plugin) ->
				)
				_t.roughDiamond.on("stop", (event, plugin) ->                          
				)
				_t.roughDiamond[0].style.setProperty 'cursor','w-resize'
				defer.resolve(@)
			)
		defer	
		
	play : () -> return		
	stop : () -> return

@SarineRoughDiamond = SarineRoughDiamond