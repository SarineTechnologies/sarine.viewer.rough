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
		@atomConfig.ImagePattern = @atomConfig.ImagePattern.toLowerCase()
		@chaceVersion = if window.stones[0].viewers.roughCacheVersion != null then '?' + window.stones[0].viewers.roughCacheVersion else ''

	convertElement : () ->	
		@element
	        
	first_init : ()->
		defer = $.Deferred() 
		_t = @
		
		_t.$curElement = $('.viewer.roughDiamond') 
		#decide on image size
		_t.containerSize = _t.$curElement.width()
		if (_t.containerSize == 0)
			_t.containerSize = Math.min($(window).height(), $(window).width())

		if(_t.atomConfig.ImagePattern.indexOf("webp")!=-1)
			Device.isSupportsWebp().then (->
			),   ->  #if browser not support webp images
				_t.atomConfig.ImagePattern = _t.atomConfig.ImagePattern.replace(".webp",_t.atomConfig.ImageFormatFallback)
			.then ()->
				_t.loadFirstImage(defer)
		else
			_t.loadFirstImage(defer)
		defer
	
	loadFirstImage : (defer)->
		_t = @
		@firstImageName = _t.atomConfig.ImagePattern.replace("*","1")
		src = _t.domain + @firstImageName + @chaceVersion			
					
		_t.loadImage(src).then((img)->	
			if img.src.indexOf('data:image') == -1 && img.src.indexOf('no_stone') == -1			
				defer.resolve(_t)
			else  #fallback if there aren't webp images
				if(_t.atomConfig.ImagePattern.indexOf("webp")!=-1)
					_t.atomConfig.ImagePattern = _t.atomConfig.ImagePattern.replace(".webp",_t.atomConfig.ImageFormatFallback)
					src = src.replace(".webp",_t.atomConfig.ImageFormatFallback)
					_t.loadImage(src).then((img)->	
						if img.src.indexOf('data:image') == -1 && img.src.indexOf('no_stone') == -1			
							defer.resolve(_t)
						else
							_t.loadNoStone(defer,img)
					)
						
				else
					_t.loadNoStone(defer,img)
									
			)
	
	loadNoStone: (defer,img)->
				_t = @
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

	full_init : ()-> 
		defer = $.Deferred()
		if @isAvailble 
			@roughDiamond = @element			
			_t = @;
			#load all images
			_t.loadAssets(@assets,() ->
				imageNameLocal = _t.atomConfig.ImagePattern.replace('*', '{num}') + _t.chaceVersion
				_t.roughDiamond.imgplay({
					startImage: 1,
					totalImages: _t.atomConfig.NumberOfImages,
					imageName: imageNameLocal,                            
					urlDir:  _t.domain + imageNameLocal,
					height:  _t.containerSize,
					width:  _t.containerSize,
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